# Darth Linux 0.5 preview

Darth Linux 0.5 is a versioned preview build focused on desktop consistency and system maintenance. Arch Linux remains the underlying distribution and package-management base.

## Unified identity

- **Boot splash:** Darth graphite/crimson artwork and version label, rendered into the Archiso BIOS menu.
- **Login screen:** LightDM uses the same Darth desktop wallpaper and dark GTK theme.
- **Desktop:** XFCE uses the Adwaita-derived dark theme, matching terminal palette, Noto Sans typography, and Darth wallpaper.
- **File manager:** the Darth Files launcher uses the shared Darth icon and launches Thunar with the Darth GTK theme. Thunar itself remains the upstream file manager.
- **Terminal:** the Darth Terminal launcher sets a branded window title; the default shell prompt and terminal colors use Darth styling.
- **Installer:** the Darth Installer opens a branded terminal session and clearly identifies Archinstall as its underlying installer engine.
- **Settings and Control Center:** both use the same shared icon, graphite/crimson GTK styling, and 0.5 version label.

## Update Center

Open **Darth Settings → Updates**.

1. **Check for updates** runs `checkupdates --nocolor` from `pacman-contrib`, which checks a temporary package database and reports pending packages without changing the live sync database.
2. Review the package names and versions displayed in the details panel.
3. **Install system updates** requests administrator authentication through PolicyKit and then runs a complete `pacman -Syu` transaction. Arch Linux is a rolling-release distribution; the updater deliberately does not perform partial upgrades.
4. When Flatpak is installed, **Update Flatpak apps** updates apps and runtimes in the current user's Flatpak installation. Darth Store currently installs its Flatpak apps per-user.

System update output is saved to `~/.local/state/darth-linux/system-update.log`. A restart is recommended after core system, kernel, or driver updates.

Updates are user-initiated; this preview does not silently download or install operating-system updates in the background. Keep the device powered and connected during an upgrade. Do not power off while pacman is installing packages.

## Version and build

The repository `VERSION` file controls the ISO name and embedded `/etc/darth-linux-release`. Version 0.5 builds as `darth-linux-0.5` and the GitHub Actions artifact is `darth-linux-0.5-live-iso`.

Build on an updated Arch Linux host:

```bash
sudo pacman -Syu --needed git\nsudo pacman -Syu --needed git\ngit clone https://github.com/Screwyougucci/DarthLinux.git
cd DarthLinux
sudo bash build.sh
```

## Known limitations

- This is a preview, not a stable release.
- The installer is a branded handoff to upstream Archinstall, not a separate fork of Archinstall.
- Darth Files is a themed launcher for upstream Thunar, not a fork of Thunar.
- Update Center requires working repository mirrors, internet connectivity, `pacman-contrib`, and an active PolicyKit authentication agent.
- Flatpak updates are only available if Flatpak is installed; per-user updates do not update system-wide Flatpak applications.
- The new updater and desktop branding still require runtime tests in the built ISO and an installed system.
- A successful ISO build is not proof of successful installation, hardware compatibility, encryption, or update behavior.

See [the testing checklist](TESTING.md) before treating this preview as ready for daily use.
