# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="372eb64e870d09afde1e414ddff838ae90a1baa8"

inherit toolchain-funcs cros-workon

DESCRIPTION="Utility that dumps a png image to the frame buffer."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

DEPEND="media-libs/libpng"
RDEPEND="${DEPEND}"

src_compile() {
	if tc-is-cross-compiler ; then
		tc-getCC
	fi
	emake || die "emake failed"
}

src_install() {
	mkdir -p "${D}/usr/bin"
	cp "${S}/src/ply-image" "${D}/usr/bin"
}
