# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

DESCRIPTION="Open source CoreSight trace decode library"
HOMEPAGE="https://github.com/Linaro/OpenCSD"
SRC_URI="https://github.com/linaro/${PN}/archive/${P}.tar.xz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="debug"

RDEPEND=""

src_compile() {
	cros_enable_cxx_exceptions
	use debug && DEBUG_OPT=1

	emake -C decoder/build/linux/ \
		LINUX64=1 DEBUG=${DEBUG_OPT} \
		MASTER_CC="$(tc-getCC)" \
		MASTER_CXX="$(tc-getCXX)" \
		MASTER_LINKER="$(tc-getCXX)"
}

src_install() {
	emake -C decoder/build/linux/ \
		PREFIX="${ED}"/usr \
		LIB_PATH="$(get_libdir)" \
		install
}