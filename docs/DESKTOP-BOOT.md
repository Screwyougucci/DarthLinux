# Darth Linux desktop at boot

Darth Linux is configured to start in a graphical session instead of dropping the user at a text-only target.

## Boot flow

- systemd's default target is set to `graphical.target`.
- LightDM is configured as the display manager.
- The user reaches a graphical login screen; the image does not silently auto-login as root.
- XFCE is the desktop environment.

## Default desktop layout

The default XFCE panel is configured with:
- Whisker application menu for browsing installed applications by category and searching for apps.
- Task list for open windows.
- System tray.
- PipeWire/PulseAudio volume control.
- Clock.

Plank starts automatically as the bottom dock. Its pinned launchers include Firefox, Darth Files, Darth Terminal, Darth Settings, Darth Control Center, and Darth AI Model Manager.

NetworkManager, Bluetooth, and XFCE power-manager tray applets start with the desktop session. The default application menu exposes the rest of the installed applications, including the security, VM, media, and diagnostic tools.

## Apps and settings

The Updates, Audio, Display, Video, Network, Security, and System settings hub is launched with `darth-settings`. All installed desktop applications also appear in the Whisker menu. Hardware controls only appear or function when supported by the computer.

## Live image vs installed system

The LightDM and desktop defaults are part of the Archiso image. The live image still needs a build and boot test to verify the display-manager login flow, desktop session, dock, tray applets, and package availability. The Darth Installer launches upstream Archinstall. After installing to disk and rebooting, connect to the internet, run `sudo pacman -Syu --needed git`, clone the project repository, and run `sudo bash scripts/install-custom-tools.sh` to install the full Darth package set, tools, theme, icon, firewall defaults, and Update Center. This post-install step is required; Archinstall itself installs the base Arch system and does not automatically copy the Darth project overlay.
