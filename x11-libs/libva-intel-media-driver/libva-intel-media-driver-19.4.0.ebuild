# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CMAKE_BUILD_TYPE="Release"
inherit cmake-utils

if [[ ${PV} == *9999 ]] ; then
	: ${EGIT_REPO_URI:="https://github.com/intel/media-driver"}
	if [[ ${PV%9999} != "" ]] ; then
		: ${EGIT_BRANCH:="release/${PV%.9999}"}
	fi
	inherit git-r3
fi

DESCRIPTION="Intel Media Driver for VAAPI (iHD)"
HOMEPAGE="https://github.com/intel/media-driver"
if [[ ${PV} == *9999 ]] ; then
	SRC_URI=""
	KEYWORDS=""
else
	SRC_URI="https://github.com/intel/media-driver/archive/intel-media-${PV}r.tar.gz"
	S="${WORKDIR}/media-driver-intel-media-${PV}r"
	KEYWORDS="*"
fi

LICENSE="MIT BSD"
SLOT="0"
IUSE="ihd_cmrtlib"

DEPEND=">=media-libs/gmmlib-19.4.1
	>=x11-libs/libva-2.6.0
	>=x11-libs/libpciaccess-0.10
"
RDEPEND="${DEPEND}"

# The 2nd patch below disables IPC usage by explicitly defining the ANDROID
# macro.  It is needed for the media driver to work within the Chrome OS
# sandbox.  An upstream bug has been filed, requesting for a more meaningful
# name than ANDROID that can be switched on or off when calling cmake.
# The bug is https://github.com/intel/media-driver/issues/854.
#
# The 3rd patch below is a temporary workaround to address a video
# hardware decoding regression observed on Chrome OS on Gen12.
PATCHES=(
	"${FILESDIR}"/0001-Encoder-VP8-GEN9-GEN10-GEN11-Ensure-forced_lf_adjust.patch
	"${FILESDIR}"/0002-Disable-IPC-usage.patch
	"${FILESDIR}"/0003-Partially-revert-VP-Fix-aux-mapping-issue.patch
	"${FILESDIR}"/0004-Fix-Clang-Warning.patch
	"${FILESDIR}"/0005-use-gmmlib-calculate-the-NV12-surface-offset.patch
	"${FILESDIR}"/0006-Ignore-the-private-VP9-status-buffer.patch
	"${FILESDIR}"/0007-add-SW-WA-to-diable-calculation-of-the-UV-offset-by-gmmlib-on-TGL.patch
	"${FILESDIR}"/0008-VP-Explicitly-initialize-maxSrcRect-of-VpHalRenderer.patch
	"${FILESDIR}"/0009-VP-fix-crash-in-vp8-playback.patch
	"${FILESDIR}"/0010-VP-fix-illegal-access-and-mem-leak.patch
	"${FILESDIR}"/0011-Media-Common-Fix-tiling-issue.patch
	"${FILESDIR}"/0012-Media-Common-Modify-the-default-tile-type.patch
	"${FILESDIR}"/0013-Add-external-surface-support.patch
	"${FILESDIR}"/0014-VP-Fix-memory-corruption-due-to-improper-typecast.patch
	"${FILESDIR}"/0015-Support-up-to-8Kx8K-VP9-encoding-on-GEN12.patch
	"${FILESDIR}"/0016-Decoder-VP9-GEN-9-10-11-12-Fix-the-GPU-hang-due-to-w.patch
)

src_configure() {
	local mycmakeargs=(
		-DMEDIA_VERSION="19.4.0"
		-DMEDIA_RUN_TEST_SUITE=OFF
		-DINSTALL_DRIVER_SYSCONF=OFF
		"-DBUILD_CMRTLIB=$(usex ihd_cmrtlib ON OFF)"
		-DCMAKE_DISABLE_FIND_PACKAGE_X11=TRUE
	)

	append-cxxflags "-Wno-tautological-constant-out-of-range-compare"
	append-cxxflags "-Wno-sizeof-array-div"
	append-cxxflags "-Wno-range-loop-analysis"
	append-cxxflags "-Wno-range-loop-construct"
	append-cxxflags "-Wno-non-c-typedef-for-linkage"

	cmake-utils_src_configure
}
