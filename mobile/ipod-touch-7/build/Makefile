SHELL := /bin/sh
.PHONY: help check-host check-sources build clean

help:
	@printf '%s\n' 'Darth Linux Mobile build targets:' '  check-host     Check Linux build dependencies' '  check-sources  Verify Sandcastle source checkout paths' '  build          Run the pinned upstream Buildroot build' '  clean          Remove generated output'

check-host:
	@sh ../scripts/check-host.sh

check-sources:
	@test -n "$(SANDCASTLE_DIR)" || (echo "Set SANDCASTLE_DIR to a local Project Sandcastle checkout" >&2; exit 2)
	@test -d "$(SANDCASTLE_DIR)/loader" || (echo "Missing Sandcastle loader directory" >&2; exit 2)
	@test -n "$(BUILDROOT_DIR)" || (echo "Set BUILDROOT_DIR to the compatible Buildroot checkout" >&2; exit 2)
	@test -f "$(BUILDROOT_DIR)/Makefile" || (echo "BUILDROOT_DIR is not a Buildroot source tree" >&2; exit 2)
	@echo "Source directories found. Compatibility/configuration is not yet validated."

build: check-host check-sources
	@echo "STOP: a device-matched Sandcastle Buildroot defconfig has not yet been pinned."
	@echo "No generic rootfs will be substituted for the iPod9,1 configuration."
	@exit 3

clean:
	rm -rf output
