# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-cpp/gtest/gtest-1.6.0-r1.ebuild,v 1.13 2013/02/28 15:47:14 jer Exp $

EAPI="4"
PYTHON_DEPEND="2"

inherit eutils python autotools cros-au

MY_PN=${PN%32}
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Google C++ Testing Framework"
HOMEPAGE="http://code.google.com/p/googletest/"
SRC_URI="http://googletest.googlecode.com/files/${MY_P}.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~amd64-fbsd ~x86-fbsd ~ppc-macos"
IUSE="32bit_au"
RESTRICT="test"

DEPEND="app-arch/unzip"
RDEPEND=""

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	python_pkg_setup
	python_set_active_version 2
}

src_prepare() {
	sed -i -e "s|/tmp|${T}|g" test/gtest-filepath_test.cc || die
	sed -i -r \
		-e '/^install-(data|exec)-local:/s|^.*$|&\ndisabled-&|' \
		Makefile.am || die
	epatch "${FILESDIR}"/configure-fix-pthread-linking.patch || die
	eautoreconf

	python_convert_shebangs -r 2 .
}

src_configure() {
	board_setup_32bit_au_env
	econf --disable-shared --enable-static
}

src_test() {
	# explicitly use parallel make
	emake check || die
}

src_install() {
	dolib.a lib/.libs/libgtest{,_main}.a
}
