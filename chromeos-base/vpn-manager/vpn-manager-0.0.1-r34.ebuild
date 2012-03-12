# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="487188eb5998415be23a3e0032b662039a861aa4"
CROS_WORKON_PROJECT="chromiumos/platform/vpn-manager"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="VPN tools"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND="chromeos-base/libchrome:0[cros-debug=]
	 chromeos-base/libchromeos
	 dev-cpp/gflags
	 dev-libs/openssl
	 net-dialup/xl2tpd
	 net-misc/strongswan[cisco,nat-transport]"
DEPEND="${RDEPEND}
	 dev-cpp/gtest"

src_compile() {
	tc-export CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	emake || die "vpn-manager compile failed."
}

src_test() {
	tc-export CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	emake tests || die "could not build tests"
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
