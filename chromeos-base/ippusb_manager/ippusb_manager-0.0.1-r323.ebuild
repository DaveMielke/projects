# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="67180e7bfddaa57af74bf6ef9b1e5902facd3358"
CROS_WORKON_TREE=("6cadd9f53ad2c518aa18312d8ea45915a3dd112a" "34d1dc1b4e5659305c23d29fdfb18c99e61f4ed7" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk ippusb_manager .gn"

PLATFORM_SUBDIR="ippusb_manager"

inherit cros-workon platform udev user

DESCRIPTION="Service which manages communication between ippusb printers and cups."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/ippusb_manager/"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE=""

COMMON_DEPEND="
	chromeos-base/minijail:=
	virtual/libusb:1=
"
RDEPEND="
	${COMMON_DEPEND}
	chromeos-base/ippusb_bridge
"
DEPEND="${COMMON_DEPEND}"

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

	# Install fuzzer
	platform_fuzzer_install "${S}"/OWNERS \
		"${OUT}"/ippusb_manager_usb_fuzzer
}