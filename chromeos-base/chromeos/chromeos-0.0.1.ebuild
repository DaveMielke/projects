# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="Chrome OS (meta package)"
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="bluetooth bootchart bootimage coreboot cros_ec cros_embedded gdmwimax
	opengles X"

################################################################################
#
# READ THIS BEFORE ADDING PACKAGES TO THIS EBUILD!
#
################################################################################
#
# Every chromeos dependency (along with its dependencies) is included in the
# release image -- more packages contribute to longer build times, a larger
# image, slower and bigger auto-updates, increased security risks, etc. Consider
# the following before adding a new package:
#
# 1. Does the package really need to be part of the release image?
#
# Some packages can be included only in the developer or test images, i.e., the
# chromeos-dev or chromeos-test ebuilds. If the package will eventually be used
# in the release but it's still under development, consider adding it to
# chromeos-dev initially until it's ready for production.
#
# 2. Why is the package a direct dependency of the chromeos ebuild?
#
# It makes sense for some packages to be included as a direct dependency of the
# chromeos ebuild but for most it doesn't. The package should be added as a
# direct dependency of the ebuilds for all packages that actually use it -- in
# time, this ensures correct builds and allows easier cleanup of obsolete
# packages. For example, if a utility will be invoked by the session manager,
# its package should be added as a dependency in the chromeos-login ebuild. Or
# if the package adds a daemon that will be started through an upstart job, it
# should be added as a dependency in the chromeos-init ebuild. If the package
# really needs to be a direct dependency of the chromeos ebuild, consider adding
# a comment why the package is needed and how it's used.
#
# 3. Are all default package features and dependent packages needed?
#
# The release image should include only packages and features that are needed in
# the production system. Often packages pull in features and additional packages
# that are never used. Review these and consider pruning them (e.g., through USE
# flags).
#
# 4. What is the impact on the image size?
#
# Before adding a package, evaluate the impact on the image size. If the package
# and its dependencies increase the image size significantly, consider
# alternative packages or approaches.
#
# 5. Is the package needed on all targets?
#
# If the package is needed only on some target boards, consider making it
# conditional through USE flags in the board overlays.
#
# Variable Naming Convention:
# ---------------------------
# CROS_COMMON_* : Dependencies common to all CrOS flavors
# CROS_E_* : Dependencies for embedded CrOS devices (busybox, no X etc)
# CROS_* : Dependencies for "regular" CrOS devices (coreutils, X etc)
################################################################################

################################################################################
#
# Per Package Comments:
# --------------------
# Please add any comments specific to why certain packages are
# pulled into the dependecy here. This is optional and required only when
# the dependency isn't obvious
#
################################################################################

################################################################################
#
# CROS_COMMON_* : Dependencies common to all CrOS flavors (embedded, regular)
#
################################################################################

CROS_COMMON_RDEPEND="
	app-admin/rsyslog
	bluetooth? ( net-wireless/bluez )
	bootchart? ( app-benchmarks/bootchart )
	app-shells/dash
	chromeos-base/bootstat
	chromeos-base/chromeos-base
	chromeos-base/chromeos-fonts
	chromeos-base/chromeos-installer
	chromeos-base/crash-reporter
	chromeos-base/metrics
	chromeos-base/root-certificates
	chromeos-base/shill
	chromeos-base/update_engine
	coreboot? ( virtual/chromeos-coreboot )
	gdmwimax? ( net-wireless/gdmwimax )
	net-firewall/iptables
	net-misc/tlsdate
	sys-apps/baselayout
	sys-apps/coreutils
	sys-apps/grep
	sys-apps/mawk
	sys-apps/net-tools
	sys-apps/sed
	sys-apps/util-linux
	sys-apps/which
	sys-libs/timezone-data
	sys-process/procps
	virtual/chromeos-bsp
	virtual/chromeos-firmware
	virtual/linux-sources
	virtual/modutils
"
CROS_COMMON_DEPEND="${CROS_COMMON_RDEPEND}
	bootimage? ( sys-boot/chromeos-bootimage )
	cros_ec? ( chromeos-base/chromeos-ec )
"

################################################################################
#
# CROS_* : Dependencies for "regular" CrOS devices (coreutils, X etc)
#
# Comments on individual packages:
# --------------------------------
# app-editors/vim:
# Specifically include the editor we want to appear in chromeos images, so that
# it is deterministic which editor is chosen by 'virtual/editor' dependencies
# (such as in the 'sudo' package).  See crosbug.com/5777.
#
# app-shells/bash:
# We depend on dash for the /bin/sh shell for runtime speeds, but we also
# depend on bash to make the dev mode experience better.  We do not enable
# things like line editing in dash, so its interactive mode is very bare.
# media-plugins/o3d:
# Note that o3d works with opengl on x86 and opengles on ARM, but not ARM
# opengl.
#
# dev-util/quipper:
# This is needed to support profiling live ChromiumOS systems.
#
# sys-apps/which:
# In gentoo, the 'which' command is part of 'system' and certain packages
# assume sys-apps/which is already installed, since we dont install 'system'
# explicitly list sys-apps/which.
#
# net-wireless/realtek-rt2800-firmware:
# USB / WiFi Firmware.
#
# app-i18n/ibus-*:
# The ibus implementation of text input conversion engines.
# TODO(nona): Remove all ibus engines. crbug.com/i171351
#
# app-i18n/nacl-mozc:
# An text input processors based on IME extension APIs.
################################################################################

CROS_X86_RDEPEND="
	sys-boot/syslinux
	media-plugins/o3d
"
CROS_ARM_RDEPEND="
	chromeos-base/u-boot-scripts
	opengles? ( media-plugins/o3d )
"

CROS_X_RDEPEND="
	chromeos-base/chromeos-chrome
	chromeos-base/chromeos-fonts
	chromeos-base/xorg-conf
	x11-apps/xinit
	x11-apps/xrandr
	x11-apps/xset-mini
	x11-base/xorg-server
"

CROS_RDEPEND="
	x86? ( ${CROS_X86_RDEPEND} )
	amd64? ( ${CROS_X86_RDEPEND} )
	arm? ( ${CROS_ARM_RDEPEND} )
	X? ( ${CROS_X_RDEPEND} )
"

CROS_RDEPEND="${CROS_RDEPEND}
	app-arch/sharutils
	app-arch/tar
	app-crypt/trousers
	app-editors/vim
	app-i18n/ibus-english-m
	app-i18n/ibus-m17n
	app-i18n/ibus-mozc
	app-i18n/ibus-mozc-chewing
	app-i18n/ibus-mozc-hangul
	app-i18n/ibus-mozc-pinyin
	app-i18n/nacl-mozc
	app-laptop/laptop-mode-tools
	app-shells/bash
	chromeos-base/audioconfig
	chromeos-base/board-devices
	chromeos-base/chromeos-assets
	chromeos-base/chromeos-assets-split
	chromeos-base/chromeos-auth-config
	chromeos-base/chromeos-debugd
	chromeos-base/chromeos-imageburner
	chromeos-base/chromeos-init
	chromeos-base/chromeos-login
	chromeos-base/cros-disks
	chromeos-base/cros_boot_mode
	chromeos-base/crosh
	chromeos-base/dev-install
	chromeos-base/inputcontrol
	chromeos-base/internal
	chromeos-base/mtpd
	chromeos-base/permission_broker
	chromeos-base/power_manager
	chromeos-base/userfeedback
	chromeos-base/vboot_reference
	dev-util/quipper
	media-gfx/ply-image
	media-plugins/alsa-plugins
	media-sound/adhd
	media-sound/alsa-utils
	net-wireless/ath3k
	net-wireless/ath6k
	net-wireless/crda
	net-wireless/marvell_sd8787
	net-wireless/realtek-rt2800-firmware
	sys-apps/bootcache
	sys-apps/dbus
	sys-apps/eject
	sys-apps/flashrom
	sys-apps/mosys
	sys-apps/pv
	sys-apps/rootdev
	sys-apps/shadow
	sys-apps/upstart
	sys-apps/ureadahead
	sys-auth/pam_pwdfile
	sys-fs/e2fsprogs
	sys-fs/udev
	sys-process/lsof
"

# Build time dependencies
CROS_DEPEND="${CROS_RDEPEND}
"

################################################################################
# CROS_E_* : Dependencies for embedded CrOS devices (busybox, no X etc)
#
################################################################################

CROS_E_RDEPEND="${CROS_E_RDEPEND}
	sys-apps/shadow
	sys-apps/util-linux
	chromeos-base/chromeos-embedded-init
"

# Build time dependencies
CROS_E_DEPEND="${CROS_E_RDEPEND}
"

################################################################################
# Assemble the final RDEPEND and DEPEND variables for portage
################################################################################
RDEPEND="${CROS_COMMON_RDEPEND}
	cros_embedded? ( ${CROS_E_RDEPEND} )
	!cros_embedded? ( ${CROS_RDEPEND} )
"

DEPEND="${CROS_COMMON_DEPEND}
	cros_embedded? ( ${CROS_E_DEPEND} )
	!cros_embedded? ( ${CROS_DEPEND} )
"
