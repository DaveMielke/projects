# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="940ca4da805d83c9e25919c7146bee62523d6c57"
CROS_WORKON_TREE=("03bbbcee411f17ba1fc689765743cc4876d16cbb" "2c9e675805cf0a18eb8992cc1d6f3650d3dbb8ad" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk goldfishd .gn"

PLATFORM_SUBDIR="goldfishd"

inherit cros-workon platform

DESCRIPTION="Android Emulator Daemon for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/goldfishd/"

LICENSE="BSD-Google"
SLOT="0/0"
KEYWORDS="*"

RDEPEND="
	chromeos-base/autotest-client
	"

src_install() {
	dobin "${OUT}"/goldfishd

	insinto /etc/init
	doins init/*.conf
}

platform_pkg_test() {
	platform_test "run" "${OUT}/goldfishd_test_runner"
}
