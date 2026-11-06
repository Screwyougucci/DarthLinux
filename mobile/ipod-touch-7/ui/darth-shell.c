#define _POSIX_C_SOURCE 200809L
#include <errno.h>
#include <fcntl.h>
#include <linux/fb.h>
#include <linux/input.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <unistd.h>

struct surface {
    uint8_t *pixels;
    uint32_t width, height, stride, bpp;
    struct fb_var_screeninfo var;
    size_t length;
};

static uint32_t channel(uint8_t value, struct fb_bitfield field) {
    if (field.length == 0U) return 0U;
    uint32_t max = (1U << field.length) - 1U;
    return (((uint32_t)value * max + 127U) / 255U) << field.offset;
}

static uint32_t pack_rgb(const struct fb_var_screeninfo *v,
                         uint8_t r, uint8_t g, uint8_t b) {
    return channel(r, v->red) | channel(g, v->green) |
           channel(b, v->blue) | channel(255U, v->transp);
}

static void put_pixel(struct surface *s, int x, int y, uint32_t color) {
    if (x < 0 || y < 0 || (uint32_t)x >= s->width ||
        (uint32_t)y >= s->height) return;
    uint8_t *p = s->pixels + (size_t)y * s->stride +
                 (size_t)x * (s->bpp / 8U);
    for (uint32_t i = 0; i < s->bpp / 8U; ++i)
        p[i] = (uint8_t)(color >> (i * 8U));
}

static void rect(struct surface *s, int x, int y, int w, int h,
                 uint32_t color) {
    if (w <= 0 || h <= 0) return;
    for (int yy = y; yy < y + h; ++yy)
        for (int xx = x; xx < x + w; ++xx)
            put_pixel(s, xx, yy, color);
}

static const uint8_t *glyph(char c) {
    static const uint8_t blank[5] = {0,0,0,0,0};
    static const uint8_t table[37][5] = {
        {31,5,5,5,31},{30,5,5,5,30},{31,17,17,17,17},
        {31,17,17,10,4},{31,21,21,17,17},{31,5,5,1,1},
        {14,17,21,21,29},{31,4,4,4,31},{17,17,31,17,17},
        {8,16,16,16,15},{31,4,10,17,0},{31,16,16,16,16},
        {31,2,4,2,31},{31,2,4,8,31},{14,17,17,17,14},
        {31,5,5,5,2},{14,17,25,17,30},{31,5,13,21,2},
        {18,21,21,21,9},{1,1,31,1,1},{15,16,16,16,15},
        {7,8,16,8,7},{31,8,4,8,31},{17,10,4,10,17},
        {1,2,28,2,1},{17,25,21,19,17},
        {14,17,17,17,14},{4,12,4,4,14},{14,17,2,4,31},
        {30,1,6,1,30},{2,6,10,31,2},{31,16,30,1,30},
        {14,16,30,17,14},{31,1,2,4,4},{14,17,14,17,14},
        {14,17,15,1,14},{0,0,0,0,4}
    };
    if (c >= 'A' && c <= 'Z') return table[(unsigned)(c - 'A')];
    if (c >= '0' && c <= '9') return table[26U + (unsigned)(c - '0')];
    if (c == '-') return table[36];
    return blank;
}

static void text(struct surface *s, int x, int y, const char *str,
                 int scale, uint32_t color) {
    for (; *str; ++str, x += 6 * scale) {
        const uint8_t *g = glyph(*str);
        for (int col = 0; col < 5; ++col)
            for (int row = 0; row < 5; ++row)
                if ((g[col] & (1U << row)) != 0U)
                    rect(s, x + col * scale, y + row * scale,
                         scale, scale, color);
    }
}

static void render(struct surface *s, int selected) {
    const uint32_t bg = pack_rgb(&s->var, 15, 17, 22);
    const uint32_t panel = pack_rgb(&s->var, 29, 32, 40);
    const uint32_t red = pack_rgb(&s->var, 190, 24, 48);
    const uint32_t white = pack_rgb(&s->var, 238, 240, 244);
    const uint32_t muted = pack_rgb(&s->var, 155, 161, 173);
    rect(s, 0, 0, (int)s->width, (int)s->height, bg);
    rect(s, 0, 0, (int)s->width, 7, red);
    text(s, 18, 22, "DARTH MOBILE", 2, white);
    text(s, 18, 42, "IPOD TOUCH 7 - EARLY UI", 1, muted);
    int margin = (int)(s->width / 16U);
    int gap = 12;
    int top = (int)(s->height / 3U);
    int card_w = ((int)s->width - 2 * margin - gap) / 2;
    int card_h = (int)(s->height / 7U);
    const char *labels[4] = {"FILES", "TERMINAL", "NETWORK", "SETTINGS"};
    for (int i = 0; i < 4; ++i) {
        int x = margin + (i % 2) * (card_w + gap);
        int y = top + (i / 2) * (card_h + gap);
        rect(s, x, y, card_w, card_h, panel);
        rect(s, x, y, 4, card_h, i == selected ? red : muted);
        text(s, x + 14, y + 15, labels[i], 2, white);
    }
    text(s, 18, (int)s->height - 24, "FRAMEBUFFER MODE - NO GPU REQUIRED",
         1, muted);
}

static int self_test(void) {
    struct fb_var_screeninfo v;
    memset(&v, 0, sizeof(v));
    v.red.offset = 11; v.red.length = 5;
    v.green.offset = 5; v.green.length = 6;
    v.blue.offset = 0; v.blue.length = 5;
    uint32_t red = pack_rgb(&v, 255, 0, 0);
    uint32_t green = pack_rgb(&v, 0, 255, 0);
    uint32_t blue = pack_rgb(&v, 0, 0, 255);
    if (red != 0xf800U || green != 0x07e0U || blue != 0x001fU) {
        fputs("FAIL: RGB565 packing\n", stderr);
        return 1;
    }
    struct surface s;
    memset(&s, 0, sizeof(s));
    uint8_t pixels[32 * 32 * 4];
    memset(pixels, 0, sizeof(pixels));
    s.pixels = pixels; s.width = 32; s.height = 32;
    s.stride = 32 * 4; s.bpp = 32;
    put_pixel(&s, 31, 31, 0x12345678U);
    if (pixels[(31U * 32U + 31U) * 4U] != 0x78U) {
        fputs("FAIL: framebuffer bounds/pixel write\n", stderr);
        return 1;
    }
    put_pixel(&s, 32, 31, 0xffffffffU);
    puts("PASS: RGB565 packing and bounded framebuffer pixel writes");
    return 0;
}

static int open_framebuffer(const char *path, struct surface *s, int *fd) {
    struct fb_fix_screeninfo fix;
    *fd = open(path, O_RDWR | O_CLOEXEC);
    if (*fd < 0) { perror("open framebuffer"); return -1; }
    if (ioctl(*fd, FBIOGET_FSCREENINFO, &fix) < 0 ||
        ioctl(*fd, FBIOGET_VSCREENINFO, &s->var) < 0) {
        perror("query framebuffer"); close(*fd); return -1;
    }
    s->width = s->var.xres; s->height = s->var.yres;
    s->bpp = s->var.bits_per_pixel; s->stride = fix.line_length;
    s->length = fix.smem_len;
    if (s->width == 0U || s->height == 0U ||
        (s->bpp != 16U && s->bpp != 24U && s->bpp != 32U)) {
        fputs("Unsupported framebuffer geometry or pixel depth\n", stderr);
        close(*fd); return -1;
    }
    s->pixels = mmap(NULL, s->length, PROT_READ | PROT_WRITE,
                     MAP_SHARED, *fd, 0);
    if (s->pixels == MAP_FAILED) { perror("mmap framebuffer"); close(*fd); return -1; }
    return 0;
}

static void touch_loop(struct surface *s, const char *input, int input_fd) {
    struct input_absinfo ax, ay;
    int have_axes = ioctl(input_fd, EVIOCGABS(ABS_X), &ax) == 0 &&
                    ioctl(input_fd, EVIOCGABS(ABS_Y), &ay) == 0 &&
                    ax.maximum > ax.minimum && ay.maximum > ay.minimum;
    if (!have_axes) {
        fputs("Touch axis ranges unavailable; showing static launcher.\n", stderr);
        return;
    }
    int selected = 0, down = 0;
    struct input_event ev;
    render(s, selected);
    while (read(input_fd, &ev, sizeof(ev)) == (ssize_t)sizeof(ev)) {
        if (ev.type == EV_KEY && ev.code == BTN_TOUCH) down = ev.value != 0;
        if (ev.type == EV_ABS && down && (ev.code == ABS_X || ev.code == ABS_Y)) {
            static int tx = 0, ty = 0;
            if (ev.code == ABS_X) tx = ev.value;
            if (ev.code == ABS_Y) ty = ev.value;
            int x = (tx - ax.minimum) * (int)s->width /
                    (ax.maximum - ax.minimum);
            int y = (ty - ay.minimum) * (int)s->height /
                    (ay.maximum - ay.minimum);
            int col = x < (int)s->width / 2 ? 0 : 1;
            int row = y < (int)s->height * 2 / 3 ? 0 : 1;
            selected = row * 2 + col;
            render(s, selected);
        }
    }
    (void)input;
}

int main(int argc, char **argv) {
    const char *fb = "/dev/fb0", *input = NULL;
    for (int i = 1; i < argc; ++i) {
        if (strcmp(argv[i], "--self-test") == 0) return self_test();
        if (strcmp(argv[i], "--fb") == 0 && i + 1 < argc) fb = argv[++i];
        else if (strcmp(argv[i], "--input") == 0 && i + 1 < argc) input = argv[++i];
        else if (strcmp(argv[i], "--help") == 0) {
            puts("Usage: darth-shell [--fb /dev/fb0] [--input /dev/input/eventX] [--self-test]");
            return 0;
        } else {
            fprintf(stderr, "Unknown or incomplete option: %s\n", argv[i]);
            return 2;
        }
    }
    struct surface s;
    memset(&s, 0, sizeof(s));
    int fbfd = -1;
    if (open_framebuffer(fb, &s, &fbfd) < 0) return 1;
    render(&s, 0);
    if (input != NULL) {
        int infd = open(input, O_RDONLY | O_CLOEXEC);
        if (infd < 0) perror("open touch input");
        else { touch_loop(&s, input, infd); close(infd); }
    }
    munmap(s.pixels, s.length);
    close(fbfd);
    return 0;
}
