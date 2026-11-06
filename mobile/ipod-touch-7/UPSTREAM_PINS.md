# Pinned upstream baseline — iPod touch 7 (N112)

The mobile build uses the historical Project Sandcastle iPod 7 bring-up,
not a generic ARM64 board profile. Immutable revisions are used so upstream
branch movement cannot silently change the image.

| Component | Pinned revision | Purpose |
|---|---|---|
| Buildroot fork | corellium/sandcastle-buildroot 95af39e1b271f2b25f73b32555db92c83f916ca8 | Commit message: “Use git for tools & add BT and Touch support for iPod7”; contains the Sandcastle rootfs overlay and HX utilities package |
| Kernel | corellium/linux-sandcastle 0c2f7dda13d67bb7e06123df516f8bdb1000a79b | Sandcastle 5.4 kernel |
| Project Sandcastle utilities | corellium/projectsandcastle 03db9c6ae04141eb940f3b9f56d446f50d57fadf | Source for hx-touchd, syscfg, and hcdpack; Buildroot hxutils package is pinned to this commit |
| N112 device tree | arch/arm64/boot/dts/hx/hx-h9p-n112.dts blob 564e3a32c3cb1194cdaa253a58060eb48da71816 | Device tree identifies hardware-model N112 and the HX H9P platform |
| HX H9P kernel config | arch/arm64/configs/hx_h9p_defconfig blob 643a97e52a5a0f09457844b7487d77ed846eede9 | Enables ARM64 16 KiB pages, HX platform, framebuffer console, evdev, and HX touchscreen |

## Confirmed touchscreen software path

The N112 device tree declares an SPI touchscreen with compatible hx,touch.
The matching kernel driver registers an input device named
Hx Capacitive TouchScreen, exposes ten multitouch slots, and reports
ABS_MT_POSITION_X/Y. The Sandcastle hx-touchd utility loads the N112-specific
N112.mtprops firmware listed by the upstream overlay.

The Darth shell auto-detects that exact input-device name and reads multitouch
slot/tracking events. It does not bit-bang SPI, program the controller itself,
or guess event-node numbers.

The upstream overlay mounts the iOS APFS host volume at /hostfs with read-only
mount options. The HX firmware list points at
/hostfs/usr/share/firmware/multitouch/N112.mtprops. The upstream syscfg reader
opens its supplied syscfg file in binary read mode. The touch daemon writes
firmware/control data to the touchscreen controller over SPI; it does not
write the iOS filesystem or NAND storage.

## Security changes made by Darth

The upstream Buildroot configuration contains the default root password
alpine and enables Dropbear. Darth's build script overrides the password
during rootfs construction, then locks the root account in the post-build
stage, disables Dropbear, and removes its startup script. It also disables
the upstream Xorg/Fluxbox startup because this branch starts the framebuffer
shell instead.

No AI packages, model runtimes, assistant processes, or AI services are added.
