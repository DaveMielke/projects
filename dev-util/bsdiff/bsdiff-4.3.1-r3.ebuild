# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/bsdiff/bsdiff-4.3-r2.ebuild,v 1.1 2010/12/13 00:35:03 flameeyes Exp $

EAPI=4
CROS_WORKON_COMMIT="8c17bdc0d759c8e6da90c5f72b052ba2605a0a3a"
CROS_WORKON_TREE="2b657e543598e1805f51cd2b4606e8da8821f391"
CROS_WORKON_PROJECT="chromiumos/third_party/bsdiff"

inherit cros-workon toolchain-funcs flag-o-matic

DESCRIPTION="bsdiff: Binary Differencer using a suffix alg"
HOMEPAGE="http://www.daemonology.net/bsdiff/"
SRC_URI=""

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host"

RDEPEND="app-arch/bzip2
	cros_host? ( dev-libs/libdivsufsort )"
DEPEND="${RDEPEND}
	dev-libs/libdivsufsort"

src_configure() {
	append-lfs-flags
	tc-export CC
	makeargs=( USE_BSDIFF=y )
}

src_compile() {
	emake "${makeargs[@]}"
}

src_install() {
	emake install DESTDIR="${D}" "${makeargs[@]}"
}

pkg_preinst() {
	# We want bsdiff in the sdk and in the sysroot (for testing), but
	# we don't want it in the target image as it isn't used.
	if [[ $(cros_target) == "target_image" ]]; then
		rm "${D}"/usr/bin/bsdiff || die
	fi
}
