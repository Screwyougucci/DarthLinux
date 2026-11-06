SHELL := /bin/sh
.PHONY: help check-host check-sources ui-test build clean

help:
	@printf '%s\n' 'Darth Linux Mobile build targets:' '  check-host     Check Linux build dependencies' '  check-sources  Verify Sandcastle source checkout paths' '  ui-test        Build and test the framebuffer shell' '  build          Build the pinned N112 kernel, DTB, and rootfs' '  clean          Remove generated output'

check-host:
	@sh ../scripts/check-host.sh

ui-test:
	$(MAKE) -C ../ui test

check-sources:
	@test -n "$(SANDCASTLE_DIR)" || (echo "Set SANDCASTLE_DIR to a local Project Sandcastle checkout" >&2; exit 2)
	@test -d "$(SANDCASTLE_DIR)/loader" || (echo "Missing Sandcastle loader directory" >&2; exit 2)
	@test -n "$(BUILDROOT_DIR)" || (echo "Set BUILDROOT_DIR to the compatible Buildroot checkout" >&2; exit 2)
	@test -f "$(BUILDROOT_DIR)/Makefile" || (echo "BUILDROOT_DIR is not a Buildroot source tree" >&2; exit 2)
	@echo "Source directories found. Compatibility/configuration is not yet validated."

build: check-host
	JOBS=${JOBS:-2} bash ../scripts/build-sandcastle.sh

clean:
	rm -rf ../out/sandcastle ../out/artifacts
