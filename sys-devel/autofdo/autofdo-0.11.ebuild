# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit autotools

DESCRIPTION="Utilies for generating, examining AFDO profiles"
HOMEPAGE="http://gcc.gnu.org/wiki/AutoFDO"
SRC_URI="https://github.com/google/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="dev-libs/openssl
	sys-libs/zlib"
RDEPEND="${DEPEND}"

src_prepare() {
	eautoreconf
}

src_install() {
	dobin create_gcov create_llvm_prof dump_gcov profile_diff \
		profile_merger profile_update sample_merger
}
