# Copyright 2010 Google Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="2"
CROS_WORKON_COMMIT="42ad65261db24f0095688db695f220454568a60c"
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
	local make_flags="CC=\"$(tc-getCC)\" strip=''"
	if use arm; then
		make_flags+=" CONFIG_OGP_SPI=no CONFIG_NICINTEL_SPI=no"
		make_flags+=" CONFIG_RAYER_SPI=no CONFIG_NIC3COM=no"
		make_flags+=" CONFIG_NICREALTEK=no CONFIG_SATAMV=no"
	fi

	if use amd64; then
		# Enable dediprog programming when building for the host.
		make_flags+=" CONFIG_DEDIPROG=yes"
	fi

	emake ${make_flags} || die
}

src_install() {
	dosbin flashrom || die
	doman flashrom.8 || die
}
