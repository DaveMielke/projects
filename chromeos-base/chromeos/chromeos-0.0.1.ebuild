# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="Chrome OS (meta package)"
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="bluetooth bootchart bootimage coreboot +cras cros_ec
	cros_embedded dptf +fonts gdmwimax mtd nfc pam
	+network_time +syslog watchdog X"

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
# its package should be added as a dependency in the chromeos-login ebuild. If
# the package really needs to be a direct dependency of the chromeos ebuild,
# consider adding a comment why the package is needed and how it's used.
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
	syslog? ( app-admin/rsyslog )
	bluetooth? ( net-wireless/bluez )
	bootchart? ( app-benchmarks/bootchart )
	pam? ( chromeos-base/chromeos-auth-config )
	fonts? ( chromeos-base/chromeos-fonts )
	chromeos-base/chromeos-installer
	chromeos-base/platform2
	chromeos-base/update_engine
	coreboot? ( virtual/chromeos-coreboot )
	cras? ( chromeos-base/audioconfig media-sound/adhd )
	network_time? ( net-misc/tlsdate )
	nfc? ( net-wireless/neard chromeos-base/neard-configs )
	pam? ( sys-auth/pam_pwdfile )
	mtd? ( sys-fs/mtd-utils )
	virtual/chromeos-bsp
	virtual/chromeos-firewall
	virtual/chromeos-firmware
	virtual/chromeos-interface
	virtual/implicit-system
	virtual/linux-sources
	virtual/modutils
	virtual/service-manager
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
# app-i18n/nacl-mozc:
# A text input processors based on IME extension APIs.
#
# app-i18n/chinese-input:
# A suite of Chinese input methods based on IME extension APIs.
#
# app-i18n/chromeos-hangul
# A Hangul input processor based on extension APIs.
################################################################################

CROS_X86_RDEPEND="
	sys-boot/syslinux
	dptf? (
		sys-power/dptf
	)
"
CROS_ARM_RDEPEND="
	chromeos-base/u-boot-scripts
"

CROS_X_RDEPEND="
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
	app-i18n/chinese-input
	app-i18n/nacl-mozc
	app-i18n/chromeos-hangul
	app-laptop/laptop-mode-tools
	app-shells/bash
	chromeos-base/chromeos-assets
	chromeos-base/chromeos-assets-split
	chromeos-base/chromeos-imageburner
	chromeos-base/cros_boot_mode
	chromeos-base/crosh
	chromeos-base/dev-install
	chromeos-base/inputcontrol
	chromeos-base/internal
	chromeos-base/mtpd
	chromeos-base/permission_broker
	chromeos-base/userfeedback
	chromeos-base/vboot_reference
	net-wireless/ath3k
	net-wireless/ath6k
	net-wireless/crda
	net-wireless/marvell_sd8787
	net-wireless/realtek-rt2800-firmware
	watchdog? ( sys-apps/daisydog )
	sys-apps/dbus
	sys-apps/flashrom
	sys-apps/mosys
	sys-apps/pv
	sys-apps/rootdev
	sys-apps/upstart
	sys-apps/ureadahead
	sys-fs/e2fsprogs
	sys-fs/udev
"

# Build time dependencies
CROS_DEPEND="${CROS_RDEPEND}
"

################################################################################
# CROS_E_* : Dependencies for embedded CrOS devices (busybox, no X etc)
#
################################################################################

CROS_E_RDEPEND="${CROS_E_RDEPEND}
	sys-apps/util-linux
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
