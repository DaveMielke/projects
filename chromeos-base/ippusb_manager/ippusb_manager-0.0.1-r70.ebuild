# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="a27f753fe66a9a15f25246303ea3cf74e7915232"
CROS_WORKON_TREE=("85db6764c18b2cd6e849d2c5e5cd3138c23f3563" "2dad01638606a02f9c63fab75ed836356e21f0b1")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk ippusb_manager"

PLATFORM_SUBDIR="ippusb_manager"

inherit cros-workon platform udev user

DESCRIPTION="Service which manages communication between ippusbxd and cups."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/ippusb_manager/"

LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"
IUSE=""

RDEPEND="
	chromeos-base/minijail
	chromeos-base/libbrillo
	net-print/ippusbxd
	virtual/libusb:1=
"

DEPEND="${RDEPEND}"

pkg_preinst() {
	enewgroup ippusb
	enewuser ippusb
}

platform_pkg_test() {
	platform_test "run" "${OUT}/ippusb_manager_testrunner"
}

src_install() {
	dobin "${OUT}"/ippusb_manager

	# udev rules.
	udev_dorules udev/*.rules

	# Install policy files.
	insinto /usr/share/policy
	newins seccomp/ippusb-manager-seccomp-${ARCH}.policy \
		ippusb-manager-seccomp.policy

	# Upstart script.
	insinto /etc/init
	doins etc/init/*.conf
}
