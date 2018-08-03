# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="630e05b6af5f76bd7f063840e543186bde40ff0a"
CROS_WORKON_TREE="42c814a9b71ac7619efa0d47b68cb55fef759095"
CROS_WORKON_BLACKLIST=1
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform/core"
CROS_WORKON_PROJECT="platform/system/core"
CROS_WORKON_REPO="https://android.googlesource.com"

PYTHON_COMPAT=( python2_7 )

inherit cros-workon multilib python-single-r1

DESCRIPTION="Library and cli tools for Android sparse files"
HOMEPAGE="https://android.googlesource.com/platform/system/core"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	${PYTHON_DEPS}
	sys-libs/zlib
"
DEPEND="
	sys-libs/zlib
"

src_unpack() {
	cros-workon_src_unpack
	S+="/${PN}"
}

src_prepare() {
	cp "${FILESDIR}/Makefile" "${S}" || die "Copying Makefile"
}

src_configure() {
	cros-workon_src_configure
	export GENTOO_LIBDIR=$(get_libdir)
	tc-export CC
}

src_install() {
	cros-workon_src_install

	python_doscript simg_dump.py
}
