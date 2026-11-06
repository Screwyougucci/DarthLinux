#define _POSIX_C_SOURCE 200809L
#include <errno.h>
#include <fcntl.h>
#include <linux/fb.h>
#include <linux/input.h>
#include <signal.h>
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

static volatile sig_atomic_t running = 1;

static void stop_handler(int signal_number) {
    (void)signal_number;
    running = 0;
}

static uint32_t channel(uint8_t value, struct fb_bitfield field) {
    if (field.length == 0U || field.length > 32U ||
        field.offset >= 32U || field.length + field.offset > 32U)
        return 0U;
    uint64_t max = field.length == 32U
        ? UINT32_MAX : ((UINT64_C(1) << field.length) - 1U);
    return (uint32_t)((((uint64_t)value * max + 127U) / 255U)
                      << field.offset);
}

static uint32_t pack_rgb(const struct fb_var_screeninfo *v,
                         uint8_t r, uint8_t g, uint8_t b) {
    return channel(r, v->red) | channel(g, v->green) |
           channel(b, v->blue) | channel(255U, v->transp);
}

static void put_pixel(struct surface *s, int x, int y, uint32_t color) {
    if (x < 0 || y < 0 || (uint32_t)x >= s->width ||
        (uint32_t)y >= s->height) return;
    size_t bytes = s->bpp / 8U;
    size_t row = (size_t)y * s->stride;
    size_t col = (size_t)x * bytes;
    if (bytes == 0U || row > s->length || col > s->length - row ||
        bytes > s->length - row - col) return;
    uint8_t *p = s->pixels + row + col;
    for (size_t i = 0; i < bytes; ++i)
        p[i] = (uint8_t)(color >> (i * 8U));
}

static void rect(struct surface *s, int x, int y, int w, int h,
                 uint32_t color) {
    if (w <= 0 || h <= 0) return;
    int64_t right = (int64_t)x + w;
    int64_t bottom = (int64_t)y + h;
    int x0 = x < 0 ? 0 : x;
    int y0 = y < 0 ? 0 : y;
    int x1 = right > s->width ? (int)s->width : (int)right;
    int y1 = bottom > s->height ? (int)s->height : (int)bottom;
    for (int yy = y0; yy < y1; ++yy)
        for (int xx = x0; xx < x1; ++xx)
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
    if (pack_rgb(&v, 255, 0, 0) != 0xf800U ||
        pack_rgb(&v, 0, 255, 0) != 0x07e0U ||
        pack_rgb(&v, 0, 0, 255) != 0x001fU) {
        fputs("FAIL: RGB565 packing\n", stderr);
        return 1;
    }

    memset(&v, 0, sizeof(v));
    v.red.offset = 16; v.red.length = 8;
    v.green.offset = 8; v.green.length = 8;
    v.blue.offset = 0; v.blue.length = 8;
    if (pack_rgb(&v, 0x12, 0x34, 0x56) != 0x00123456U) {
        fputs("FAIL: 32-bit RGB packing\n", stderr);
        return 1;
    }

    uint8_t pixels[32U * 32U * 4U];
    memset(pixels, 0, sizeof(pixels));
    struct surface s;
    memset(&s, 0, sizeof(s));
    s.pixels = pixels; s.width = 32; s.height = 32;
    s.stride = 32U * 4U; s.bpp = 32; s.length = sizeof(pixels);
    put_pixel(&s, 31, 31, 0x12345678U);
    if (pixels[(31U * 32U + 31U) * 4U] != 0x78U) {
        fputs("FAIL: last valid framebuffer pixel\n", stderr);
        return 1;
    }
    uint8_t before = pixels[0];
    put_pixel(&s, 32, 31, 0xffffffffU);
    if (pixels[0] != before) {
        fputs("FAIL: out-of-bounds pixel write\n", stderr);
        return 1;
    }
    s.length = 4U;
    put_pixel(&s, 1, 1, 0xffffffffU);
    puts("PASS: RGB565/RGB888 packing and bounded framebuffer writes");
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
    size_t bytes = s->bpp / 8U;
    uint64_t minimum_stride = (uint64_t)s->width * bytes;
    uint64_t minimum_length = (uint64_t)s->stride * s->height;
    if (fix.visual != FB_VISUAL_TRUECOLOR ||
        s->width == 0U || s->height == 0U ||
        (s->bpp != 16U && s->bpp != 24U && s->bpp != 32U) ||
        s->stride < minimum_stride || s->length == 0U ||
        minimum_length > s->length) {
        fputs("Unsupported or unsafe framebuffer geometry/format\n", stderr);
        close(*fd); return -1;
    }
    s->pixels = mmap(NULL, s->length, PROT_READ | PROT_WRITE,
                     MAP_SHARED, *fd, 0);
    if (s->pixels == MAP_FAILED) { perror("mmap framebuffer"); close(*fd); return -1; }
    return 0;
}

static int touch_loop(struct surface *s, int input_fd) {
    struct input_absinfo ax, ay;
    int mt = ioctl(input_fd, EVIOCGABS(ABS_MT_POSITION_X), &ax) == 0 &&
             ioctl(input_fd, EVIOCGABS(ABS_MT_POSITION_Y), &ay) == 0 &&
             ax.maximum > ax.minimum && ay.maximum > ay.minimum;
    if (!mt) {
        if (ioctl(input_fd, EVIOCGABS(ABS_X), &ax) < 0 ||
            ioctl(input_fd, EVIOCGABS(ABS_Y), &ay) < 0 ||
            ax.maximum <= ax.minimum || ay.maximum <= ay.minimum) {
            fputs("Touch axis ranges unavailable; launcher remains static.\\n", stderr);
            return -1;
        }
    }

    int selected = 0, down = 0, current_slot = 0;
    int slot_active[10] = {0}, slot_have_x[10] = {0}, slot_have_y[10] = {0};
    int slot_x[10] = {0}, slot_y[10] = {0};
    int legacy_x = ax.minimum, legacy_y = ay.minimum;
    int legacy_have_x = 0, legacy_have_y = 0;
    struct input_event ev;
    render(s, selected);

    while (running) {
        ssize_t count = read(input_fd, &ev, sizeof(ev));
        if (count < 0 && errno == EINTR) continue;
        if (count != (ssize_t)sizeof(ev)) {
            if (count < 0) perror("read touch input");
            break;
        }

        if (mt && ev.type == EV_ABS) {
            if (ev.code == ABS_MT_SLOT && ev.value >= 0 && ev.value < 10)
                current_slot = ev.value;
            else if (current_slot >= 0 && current_slot < 10 &&
                     ev.code == ABS_MT_TRACKING_ID) {
                slot_active[current_slot] = ev.value >= 0;
                if (ev.value >= 0) {
                    slot_have_x[current_slot] = 0;
                    slot_have_y[current_slot] = 0;
                }
            } else if (current_slot >= 0 && current_slot < 10 &&
                       ev.code == ABS_MT_POSITION_X) {
                slot_x[current_slot] = ev.value;
                slot_have_x[current_slot] = 1;
            } else if (current_slot >= 0 && current_slot < 10 &&
                       ev.code == ABS_MT_POSITION_Y) {
                slot_y[current_slot] = ev.value;
                slot_have_y[current_slot] = 1;
            }
        } else if (!mt && ev.type == EV_KEY && ev.code == BTN_TOUCH) {
            down = ev.value != 0;
        } else if (!mt && ev.type == EV_ABS) {
            if (ev.code == ABS_X) {
                legacy_x = ev.value;
                legacy_have_x = 1;
            } else if (ev.code == ABS_Y) {
                legacy_y = ev.value;
                legacy_have_y = 1;
            }
        }

        if (ev.type == EV_SYN && ev.code == SYN_REPORT) {
            int tx = legacy_x, ty = legacy_y, touched = 0;
            if (mt) {
                for (int i = 0; i < 10; ++i) {
                    if (slot_active[i] && slot_have_x[i] && slot_have_y[i]) {
                        tx = slot_x[i];
                        ty = slot_y[i];
                        touched = 1;
                        break;
                    }
                }
            } else {
                touched = down && legacy_have_x && legacy_have_y;
            }
            if (touched) {
                int64_t rx = tx < ax.minimum ? 0 :
                    (tx > ax.maximum ? ax.maximum - ax.minimum : tx - ax.minimum);
                int64_t ry = ty < ay.minimum ? 0 :
                    (ty > ay.maximum ? ay.maximum - ay.minimum : ty - ay.minimum);
                int x = (int)(rx * (s->width - 1U) / (ax.maximum - ax.minimum));
                int y = (int)(ry * (s->height - 1U) / (ay.maximum - ay.minimum));
                int col = x < (int)s->width / 2 ? 0 : 1;
                int row = y < (int)s->height * 2 / 3 ? 0 : 1;
                int next = row * 2 + col;
                if (next != selected) {
                    selected = next;
                    render(s, selected);
                }
            }
        }
    }
    return 0;
}

static int find_touch_device(void) {
    char path[64], name[256];
    for (int i = 0; i < 32; ++i) {
        (void)snprintf(path, sizeof(path), "/dev/input/event%d", i);
        int fd = open(path, O_RDONLY | O_CLOEXEC);
        if (fd < 0) continue;
        memset(name, 0, sizeof(name));
        if (ioctl(fd, EVIOCGNAME(sizeof(name)), name) >= 0 &&
            strstr(name, "Hx Capacitive TouchScreen") != NULL) {
            struct input_absinfo ax, ay;
            if (ioctl(fd, EVIOCGABS(ABS_MT_POSITION_X), &ax) == 0 &&
                ioctl(fd, EVIOCGABS(ABS_MT_POSITION_Y), &ay) == 0 &&
                ax.maximum > ax.minimum && ay.maximum > ay.minimum) {
                fprintf(stderr, "Using Sandcastle touchscreen: %s (%s)\\n", name, path);
                return fd;
            }
        }
        close(fd);
    }
    fputs("Sandcastle touchscreen not found; launcher will remain static.\\n", stderr);
    return -1;
}

int main(int argc, char **argv) {
    const char *fb = "/dev/fb0", *input = NULL;
    for (int i = 1; i < argc; ++i) {
        if (strcmp(argv[i], "--self-test") == 0) return self_test();
        if (strcmp(argv[i], "--fb") == 0 && i + 1 < argc) fb = argv[++i];
        else if (strcmp(argv[i], "--input") == 0 && i + 1 < argc) input = argv[++i];
        else if (strcmp(argv[i], "--help") == 0) {
            puts("Usage: darth-shell [--fb /dev/fb0] [--input auto|/dev/input/eventX] [--self-test]");
            return 0;
        } else {
            fprintf(stderr, "Unknown or incomplete option: %s\n", argv[i]);
            return 2;
        }
    }

    struct sigaction action;
    memset(&action, 0, sizeof(action));
    action.sa_handler = stop_handler;
    sigemptyset(&action.sa_mask);
    if (sigaction(SIGINT, &action, NULL) < 0 ||
        sigaction(SIGTERM, &action, NULL) < 0) {
        perror("sigaction"); return 1;
    }

    struct surface s;
    memset(&s, 0, sizeof(s));
    int fbfd = -1;
    if (open_framebuffer(fb, &s, &fbfd) < 0) return 1;
    render(&s, 0);

    int result = 0;
    if (input != NULL) {
        int infd = strcmp(input, "auto") == 0
            ? find_touch_device() : open(input, O_RDONLY | O_CLOEXEC);
        if (infd < 0) {
            if (strcmp(input, "auto") != 0) perror("open touch input");
        } else {
            if (touch_loop(&s, infd) < 0) result = 1;
            close(infd);
        }
    } else {
        while (running) pause();
    }

    munmap(s.pixels, s.length);
    close(fbfd);
    return result;
}
