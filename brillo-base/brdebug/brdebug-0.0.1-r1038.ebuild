# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="26aa436d672b5f9b13c4737d9564c51ec1c5052f"
CROS_WORKON_TREE="5b7a8e978d931e7384911646c5f54685fe44143f"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="brdebug"
PLATFORM_NATIVE_TEST="yes"

inherit cros-workon platform udev

DESCRIPTION="Manage device properties for Brillo debug link."
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="
	chromeos-base/libbrillo
	chromeos-base/peerd
"

DEPEND="
	${RDEPEND}
	test? ( dev-cpp/gtest )
"

src_install() {
	dobin "${OUT}"/brdebugd
	dosbin bin/setup-usb-link
}

platform_pkg_test() {
	platform_test "run" "${OUT}/brdebug_unittest"
}
