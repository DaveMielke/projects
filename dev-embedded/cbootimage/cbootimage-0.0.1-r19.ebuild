# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="56f4048a7b55e60e037c06aae38c080b00c89014"
CROS_WORKON_TREE="aed113bb1311d50c7993cf8b0e41bb36431e072f"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/third_party/cbootimage"

inherit cros-workon

DESCRIPTION="Utility for signing Tegra2 boot images"
HOMEPAGE="http://git.chromium.org"
SRC_URI=""
LICENSE="GPLv2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND=""
DEPEND=""

src_compile() {
	emake || die "emake failed"
}

src_install() {
	dodir /usr/bin
        exeinto /usr/bin

        doexe cbootimage
        doexe bct_dump
}
