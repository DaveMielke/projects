# Copyright 2010 Google Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="2"
CROS_WORKON_COMMIT="56005ae765fb251279c37a762025e690a31b2c8b"
CROS_WORKON_PROJECT="chromiumos/third_party/flashrom"

inherit cros-workon toolchain-funcs

DESCRIPTION="Utility for reading, writing, erasing and verifying flash ROM chips"
HOMEPAGE="http://flashrom.org"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="ftdi serprog"

CROS_WORKON_LOCALNAME="flashrom"

RDEPEND="sys-apps/pciutils
	ftdi? ( dev-embedded/libftdi )"

src_compile() {
	emake CC="$(tc-getCC)" STRIP="" || die "emake failed"
}

src_install() {
	dosbin flashrom || die
	doman flashrom.8 || die
}
