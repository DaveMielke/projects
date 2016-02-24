#
# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header:$
#

EAPI=4
CROS_WORKON_COMMIT="5a230ee17756dc43ff732932dcb52899c06a4d09"
CROS_WORKON_TREE="c9c7818cca59be197e4fda230a6934bbe7720bf8"
CROS_WORKON_PROJECT="chromiumos/platform/punybench"
CROS_WORKON_LOCALNAME="../platform/punybench"
inherit cros-constants cros-workon toolchain-funcs

DESCRIPTION="A set of file system microbenchmarks"
HOMEPAGE="${CROS_GIT_HOST_URL}/${CROS_WORKON_PROJECT}"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

##DEPEND="sys-libs/ncurses"

src_compile() {
	tc-export CC
	if [ "${ARCH}" == "amd64" ]; then
        PUNYARCH="x86_64"
	else
        PUNYARCH=${ARCH}
	fi
	emake BOARD="${PUNYARCH}"
}

# Exclude punybench from clang build. Clang generates deprecated symbol
# "mcount", resulting in unresolved symbol error. Upstream bug -
# https://llvm.org/bugs/show_bug.cgi?id=23969
src_prepare() {
	cros_use_gcc
	filter_clang_syntax
	cros-workon_src_prepare
}

src_configure() {
	cros-workon_src_configure
}

src_install() {
	emake install BOARD="${PUNYARCH}" DESTDIR="${D}"
}
