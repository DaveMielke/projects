# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="35dfd205ae2f71a97a8b7ecd228f1dc172cdb650"
CROS_WORKON_TREE="86638eb435f8e0495400f5973c6ee7ec8a7ad214"
CROS_WORKON_PROJECT="chromiumos/third_party/huddly-updater"

inherit cros-workon libchrome udev user

DESCRIPTION="A utility to update Huddly camera firmware"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/huddly-updater"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="test"

DEPEND="
	chromeos-base/libbrillo
	dev-libs/msgpack
	test? ( dev-cpp/gtest:= )
	virtual/libusb:1
	virtual/libudev:0="

RDEPEND="${DEPEND}
	app-arch/unzip"

src_configure() {
	cros-workon_src_configure
}

src_test() {
	if use amd64; then
		emake tests
	fi
}

src_install() {
	dosbin huddly-updater
	dosbin huddly-hpk-updater
	udev_dorules conf/99-huddly.rules
}

pkg_preinst() {
	enewuser cfm-firmware-updaters
	enewgroup cfm-firmware-updaters
}
