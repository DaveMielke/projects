# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Adds some developer niceties on top of Chrome OS for debugging."
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE="X opengl hardened"

# The dependencies here are meant to capture "all the packages
# developers want to use for development, test, or debug".  This
# category is meant to include all developer use cases, including
# software test and debug, performance tuning, hardware validation,
# and debugging failures running autotest.
#
# To protect developer images from changes in other ebuilds you
# should include any package with a user constituency, regardless of
# whether that package is included in the base Chromium OS image or
# any other ebuild.
#
# Don't include packages that are indirect dependencies: only
# include a package if a file *in that package* is expected to be
# useful.
RDEPEND="${RDEPEND}
	app-admin/sudo
	app-arch/gzip
	app-arch/tar
	app-crypt/nss
	app-crypt/tpm-tools
	x86? ( app-editors/qemacs )
	app-editors/vim
	app-shells/bash
	chromeos-base/flimflam-test
	chromeos-base/gmerge
	dev-lang/python
	dev-python/dbus-python
	dev-util/strace
	net-analyzer/netperf
	net-misc/dhcp
	net-misc/iperf
	net-misc/iputils
	net-misc/openssh
	net-misc/rsync
	net-wireless/iw
	net-wireless/wireless-tools
	sys-apps/coreutils
	sys-apps/diffutils
	sys-apps/findutils
	x86? ( sys-apps/i2c-tools )
	x86? ( sys-apps/iotools )
	sys-apps/less
	x86? ( sys-apps/pciutils )
	sys-apps/usbutils
	sys-apps/which
	hardened? ( >=sys-devel/gdb-7.1 )
	!hardened? ( sys-devel/gdb )
	sys-fs/fuse[-kernel_linux]
	sys-fs/sshfs-fuse
	sys-power/powertop
	sys-process/procps
	sys-process/psmisc
	sys-process/time
	virtual/perf
	x86? ( x11-apps/intel-gpu-tools )
	opengl? ( x11-apps/mesa-progs )
	x11-apps/xauth
	x11-apps/xdpyinfo
	x11-apps/xdriinfo
	x11-apps/xev
	x11-apps/xhost
	x11-apps/xinput
	x11-apps/xlsatoms
	x11-apps/xlsclients
	x11-apps/xmodmap
	x11-apps/xprop
	x11-apps/xrdb
	x11-apps/xset
	x11-apps/xtrace
	x11-apps/xwininfo
	"
