# N112 firmware extraction tools

This directory vendors two GPL-2.0 utilities from
[maxxponyata-sys/ipadcastle](https://github.com/maxxponyata-sys/ipadcastle),
pinned at commit bda566f4621d0688765a729ef4d78f835709b039:

- ipswget.py — reads IPSW ZIP metadata and byte ranges over HTTP
- ipswfs.py — reads a file from an APFS root filesystem image without downloading the full IPSW

The local wrapper extracts the iPod touch 7 N112 multitouch properties file
from the official iOS 15.8.8 (19H422) IPSW.

## Extract the touch firmware

Run from Linux or WSL:

```sh
python3 -m pip install -r mobile/ipod-touch-7/firmware-tools/requirements.txt
python3 mobile/ipod-touch-7/firmware-tools/extract-n112-firmware.py
```

The default source is Apple's official iPod touch 7 iOS 15.8.8 IPSW. The tool
uses HTTP range requests and extracts only
/usr/share/firmware/multitouch/N112.mtprops; it does not download the full
multi-gigabyte IPSW. To use a different IPSW URL:

```sh
python3 mobile/ipod-touch-7/firmware-tools/extract-n112-firmware.py --ipsw-url "https://example.invalid/device.ipsw"
```

If the IPSW uses a different rootfs DMG name, pass its exact ZIP entry with
--dmg. The extracted file is written to
mobile/ipod-touch-7/firmware/N112.mtprops by default. It is ignored by Git
because it is Apple firmware; do not commit it, publish it, or upload it as a
public CI artifact.

This process reads a public firmware package only. It does not connect to,
jailbreak, restore, flash, or write to the iPod. The resulting file is intended
for a local Darth Mobile build so the HX touchscreen daemon can load the
device-specific N112 firmware without mounting the iOS APFS volume.
