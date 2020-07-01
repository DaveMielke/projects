# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils

SRC_URI="https://github.com/intel/media-driver/archive/intel-media-${PV}.tar.gz"
S="${WORKDIR}/media-driver-intel-media-${PV}"
KEYWORDS="*"
DESCRIPTION="Intel Media Driver for VAAPI (iHD)"
HOMEPAGE="https://github.com/intel/media-driver"

LICENSE="MIT BSD"
SLOT="0"
IUSE=""

DEPEND=">=media-libs/gmmlib-${PV}
	>=x11-libs/libva-2.7.1
	>=x11-libs/libpciaccess-0.10:=
"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}"/0001-Encoder-VP8-GEN9-GEN10-GEN11-Ensure-forced_lf_adjust.patch
)

src_configure() {
	local mycmakeargs=(
		-DMEDIA_RUN_TEST_SUITE=OFF
		-DBUILD_CMRTLIB=OFF
		-DCMAKE_DISABLE_FIND_PACKAGE_X11=TRUE
	)

	cmake-utils_src_configure
}