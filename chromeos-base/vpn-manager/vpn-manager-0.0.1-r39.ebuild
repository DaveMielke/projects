# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="78df4dfc7d7078ccec63aa7d54c443e603bf590a"
CROS_WORKON_TREE="44dd4521f351bc3ddc8dd9b2bd3a0449a8374142"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/platform/vpn-manager"

inherit cros-debug cros-workon toolchain-funcs multilib

DESCRIPTION="VPN tools"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND="chromeos-base/libchrome:85268[cros-debug=]
	 chromeos-base/libchromeos
	 dev-cpp/gflags
	 dev-libs/openssl
	 net-dialup/xl2tpd
	 net-misc/strongswan[cisco,nat-transport]"
DEPEND="${RDEPEND}
	 dev-cpp/gtest"

make_flags() {
	echo LIBDIR="/usr/$(get_libdir)"
}

src_compile() {
	tc-export CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	emake $(make_flags) || die "vpn-manager compile failed."
}

src_test() {
	tc-export CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	emake $(make_flags) tests || die "could not build tests"
	if ! use x86 && ! use amd64 ; then
		echo Skipping unit tests on non-x86 platform
	else
		for test in ./*_test; do
			"${test}" ${GTEST_ARGS} || die "${test} failed"
		done
	fi
}

src_install() {
	into /usr || die
	dosbin "l2tpipsec_vpn" || die
	exeinto /usr/libexec/l2tpipsec_vpn || die
	doexe "bin/pluto_updown" || die
}
