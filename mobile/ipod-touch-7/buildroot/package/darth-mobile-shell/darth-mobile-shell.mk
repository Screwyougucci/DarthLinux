################################################################################
#
# darth-mobile-shell
#
################################################################################

DART_MOBILE_SHELL_VERSION = 1.0
DART_MOBILE_SHELL_SITE = $(DART_MOBILE_SOURCE_DIR)/ui
DART_MOBILE_SHELL_SITE_METHOD = local
DART_MOBILE_SHELL_LICENSE = MIT
DART_MOBILE_SHELL_LICENSE_FILES = LICENSE

define DART_MOBILE_SHELL_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -std=c11 -Wall -Wextra -Werror" \
		LDFLAGS="$(TARGET_LDFLAGS) -Wl,-z,common-page-size=0x4000 -Wl,-z,max-page-size=0x4000"
endef

define DART_MOBILE_SHELL_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/darth-shell $(TARGET_DIR)/usr/bin/darth-shell
	$(INSTALL) -D -m 0755 $(DART_MOBILE_SOURCE_DIR)/buildroot/overlay/etc/init.d/S99darth-ui $(TARGET_DIR)/etc/init.d/S99darth-ui
endef

$(eval $(generic-package))
