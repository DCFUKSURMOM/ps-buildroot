################################################################################
#
# phantom-satellite
#
################################################################################

PHANTOMSATELLITE_VERSION = 4f14e35e381f12d34b602959d93bc6981a25673c
PHANTOMSATELLITE_SITE = https://github.com/DCFUKSURMOM/Phantom-Satellite.git
PHANTOMSATELLITE_SITE_METHOD = git
PHANTOMSATELLITE_DEPENDENCIES = libgtk2 dbus-glib xlib_libXt mailcap alsa-lib unzip zip pulseaudio openssl host-python3 xz
PHANTOMSATELLITE_POST_EXTRACT_HOOKS += PHANTOMSATELLITE_PREPARE_MOZCONFIG

ifeq ($(BR2_i386)$(BR2_x86_64),y)
    PHANTOMSATELLITE_DEPENDENCIES += host-yasm
endif

define PHANTOMSATELLITE_PREPARE_MOZCONFIG
    cp -v $(PHANTOMSATELLITE_PKGDIR)/mozconfig $(@D)/.mozconfig
    echo 'mk_add_options PYTHON=$(HOST_DIR)/bin/python3' >> $(@D)/.mozconfig
    echo 'mk_add_options YASM=$(HOST_DIR)/bin/yasm' >> $(@D)/.mozconfig
    echo 'ac_add_options --target=$(GNU_TARGET_NAME)' >> $(@D)/.mozconfig
    echo 'ac_add_options --x-libraries=$(TARGET_DIR)/usr/lib' >> $(@D)/.mozconfig
    echo 'ac_add_options --x-includes=$(TARGET_DIR)/usr/include' >> $(@D)/.mozconfig
    echo 'export CC=$(TARGET_CC)' >> $(@D)/.mozconfig
    echo 'export CXX=$(TARGET_CXX)' >> $(@D)/.mozconfig
    echo 'export STRIP=$(TARGET_STRIP)' >> $(@D)/.mozconfig
    echo 'export LD=$(TARGET_LD)' >> $(@D)/.mozconfig
    echo 'export PKG_CONFIG_PATH=$(TARGET_DIR)/usr/lib/pkgconfig:$(TARGET_DIR)/usr/share/pkgconfig' >> $(@D)/.mozconfig
    echo 'export CFLAGS=$(PS_CFLAGS)' >> $(@D)/.mozconfig
    echo 'export CXXFLAGS=$(PS_CFLAGS)' >> $(@D)/.mozconfig
endef

#Set C/CXXFLAGS based on architecture
PS_CFLAGS =
ifeq ($(BR2_x86_pentium_mmx),y)
# Set Pentium MMX as minimum, Optimize for Pentium 2, disable sse/sse2, enable mmx
    PS_CFLAGS += "-m32 -march=pentium-mmx -mtune=pentium2 -mfpmath=387 -mno-sse2 -mno-sse -mmmx"
endif
ifeq ($(BR2_x86_pentium3),y)
# Optimize for Pentium 3, disable sse2 and enable sse
    PS_CFLAGS += "-m32 -march=pentium3 -mtune=pentium3 -mfpmath=sse -mno-sse2 -msse"
endif
ifeq ($(BR2_x86_pentium4),y)
# Optimize for Pentium 4 and up
    PS_CFLAGS += "-m32 -march=pentium4 -mtune=generic"
endif
ifeq ($(BR2_x86_64),y)
# Optimize for generic x86_64 since this should run on any x86_64 CPU
    PS_CFLAGS += "-march=x86-64 -mtune=generic"
endif
ifeq ($(BR2_powerpc_604e),y)
# Set PPC 604e as minimum CPU but optimize for PPC 750/G3 and up
    PS_CFLAGS += "-mcpu=604e -mtune=750"
endif
ifeq ($(BR2_powerpc64),y)
# Optimize for generic PPC64, ensure altivec is enabled, disable mcrypto
    PS_CFLAGS += "-mcpu=powerpc64 -mtune=powerpc64 -maltivec -mabi=altivec -mno-crypto"
endif
ifeq ($(BR2_aarch64),y)
# Optimize for generic aarch64
    PS_CFLAGS += "-march=armv8-a -mtune=generic"
endif


define PHANTOMSATELLITE_BUILD_CMDS
    cd $(@D) && $(TARGET_MAKE_ENV) ./mach build
endef

define PHANTOMSATELLITE_INSTALL_TARGET_CMDS
    cd $(@D) && $(TARGET_MAKE_ENV) ./mach package
    cd $(@D) && cp obj-$(GNU_TARGET_NAME)/dist/*.tar.xz $(BASE_DIR)/images
endef

$(eval $(generic-package))