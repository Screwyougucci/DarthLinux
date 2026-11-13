# Darth Linux 0.5 release checklist

- [x] Version metadata set to 0.5.
- [x] ISO build workflow configured to produce `darth-linux-0.5`.
- [ ] Complete a fresh GitHub Actions ISO build.
- [ ] Verify the ISO artifact and SHA256 checksum.
- [ ] Boot-test the image in a virtual machine.
- [ ] Publish the ISO and checksum as the v0.5 GitHub Release assets.

A successful CI build validates the build pipeline; it does not replace boot and installation testing.
