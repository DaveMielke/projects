# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CROS_WORKON_COMMIT="228dac9861b4df02de291e270450bd4689715e0d"
CROS_WORKON_TREE=("f9717b507c2df65dc05165b9415ccd3154b01ecc" "07f4ca984309c6d725b2a1b28c761b7affa7a977" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk glib-bridge .gn"

PLATFORM_SUBDIR="glib-bridge"

inherit cros-workon platform

DESCRIPTION="libchrome-glib message loop bridge"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/glib-bridge"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	dev-libs/glib:="

DEPEND="${RDEPEND}"

src_install() {
	dolib.a "${OUT}"/libglib_bridge.a

	# Install headers.
	insinto /usr/include/glib_bridge
	doins *.h
}


platform_pkg_test() {
	platform_test "run" "${OUT}/glib_bridge_test_runner"
}