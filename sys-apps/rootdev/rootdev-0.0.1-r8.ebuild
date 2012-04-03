# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="f8e5f9f2ed1a383d5726d4e55a40c7e6f9bc9744"
CROS_WORKON_TREE="7e83ab1405cac6b14d5cd4a91f122fa32e18776d"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/third_party/rootdev"

inherit toolchain-funcs cros-workon

DESCRIPTION="Chrome OS root block device tool/library"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

src_compile() {
	tc-getCC
	emake || die
}

src_install() {
	dodir /usr/bin
	exeinto /usr/bin
	doexe ${S}/rootdev

	dodir /usr/lib
	dolib.so librootdev.so*

	dodir /usr/include/rootdev
	insinto /usr/include/rootdev
	doins rootdev.h
}
