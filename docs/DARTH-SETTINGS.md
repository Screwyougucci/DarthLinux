# Darth Settings

Darth Settings is the expanded GTK4 settings hub for the XFCE desktop. Version 0.5 adds the Darth Update Center.

## Open it

After installing Darth Linux, run:

```bash
sudo bash scripts/install-custom-tools.sh
darth-settings
```

It is also available from the XFCE applications menu and from Darth Control Center.

## Audio

The Audio page provides:
- Default output volume control using `wpctl` (PipeWire).
- Output mute toggle.
- Advanced audio mixer for output/input selection, microphone levels, per-application volume, and device profiles through `pavucontrol`.
- Audio device status through `wpctl`.

PipeWire and WirePlumber are included in the image profile. Actual device availability depends on the machine and whether the user audio session is running.

## Display

- XFCE display settings for resolution, refresh rate, rotation, and multiple monitors.
- Brightness increase/decrease shortcuts using `brightnessctl`.

Brightness control requires a compatible backlight device and appropriate permissions. Desktop monitors may not expose brightness through the laptop backlight interface.

## Video and camera

- MPV for local media playback.
- Guvcview for supported webcam controls.
- V4L2 device and camera-control inspection through `v4l2-ctl`.
- FFmpeg command-line media inspection and conversion.

Camera support depends on kernel drivers, hardware, and user permissions. The settings app does not record or transmit camera content.

## Updates (Darth Linux 0.5)\n\nThe Updates page provides a Windows/macOS-style manual update workflow:\n- Check official repositories with `checkupdates --nocolor` from `pacman-contrib` and show the pending package list before changing the system.\n- Install a full system upgrade with `pkexec /usr/bin/pacman -Syu --noconfirm` after PolicyKit administrator authentication. The app does not run partial upgrades.\n- If Flatpak is installed, update apps and runtimes in the current user's Flatpak installation.\n- Save system update output to `~/.local/state/darth-linux/system-update.log`.\n\nThe user explicitly starts checks and installations. No unattended system upgrades are enabled. Keep the computer powered during an upgrade; restart after kernel or core system updates.\n\n## Other pages

Network provides NetworkManager and Darth Proxy launchers. Security provides local firewall, antivirus, and authorized lab-tool launchers. System provides hardware/resource diagnostics, task manager, VM manager, and the local AI manager.

## Dependencies

The image profile adds PipeWire, WirePlumber, pavucontrol, playerctl, brightnessctl, v4l-utils, guvcview, mpv, ffmpeg, and XFCE settings packages.

## Limitations

This is a lightweight control hub, not a replacement for every hardware vendor utility. Some controls open the appropriate existing Linux settings application rather than reimplementing low-level hardware configuration. Hardware-specific controls may be unavailable on unsupported devices. The 0.5 update workflow and settings UI still require runtime testing on a booted Darth Linux image.
