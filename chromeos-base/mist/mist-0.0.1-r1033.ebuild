# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="71cdbe67b2aeccf4793736fb2ca9d966125917a0"
CROS_WORKON_TREE="e9e334b8e5cf8edab47eeb3898a60e99ce5306a9"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="mist"

inherit cros-workon platform udev

DESCRIPTION="Chromium OS Modem Interface Switching Tool"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="
	chromeos-base/libchromeos
	chromeos-base/metrics
	dev-libs/protobuf
	net-dialup/ppp
	virtual/libusb:1
	virtual/udev
"

DEPEND="
	${RDEPEND}
	test? ( dev-cpp/gmock )
	dev-cpp/gtest
"

platform_pkg_test() {
	platform_test "run" "${OUT}/mist_testrunner"
}

src_install() {
	dobin "${OUT}"/mist

	insinto /usr/share/mist
	doins default.conf

	udev_dorules 51-mist.rules
}
