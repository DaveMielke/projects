# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_PROJECT="chromiumos/third_party/libscrypt"

inherit cros-workon toolchain-funcs autotools

DESCRIPTION="Scrypt key derivation library"
HOMEPAGE="http://www.tarsnap.com/scrypt.html"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="test"

RDEPEND="
	"

DEPEND="
	dev-libs/openssl
	${RDEPEND}"

CROS_WORKON_LOCALNAME="../third_party/libscrypt"

src_prepare() {
	epatch function_visibility.patch
	eautoreconf
}

src_configure() {
	if tc-is-cross-compiler ; then
		tc-getCC
		tc-getCXX
		tc-getAR
		tc-getRANLIB
		tc-getLD
		tc-getNM
		export CCFLAGS="$CFLAGS"
	fi

	econf || die "libscrypt configure failed."
}

src_compile() {
	if tc-is-cross-compiler ; then
		tc-getCC
		tc-getCXX
		tc-getAR
		tc-getRANLIB
		tc-getLD
		tc-getNM
		export CCFLAGS="$CFLAGS"
	fi

	emake || die "libscrypt compile failed."
}

src_install() {
  dolib ${S}/.libs/libscrypt-1.1.6.so
  dolib ${S}/.libs/libscrypt.so

  insinto "/usr/include/scrypt"
  doins ${S}/src/lib/scryptenc/scryptenc.h
}
