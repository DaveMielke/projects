# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="dcb144cbc79ad7427d03fa2b8dc7b64758bb1dd6"
CROS_WORKON_TREE="ff322aea209e7b48dc013458cff9b42625a0717d"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="glbench"

inherit cros-workon libchrome platform

DESCRIPTION="GLBench runs OpenGL or OpenGL ES performance tests"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"
IUSE="opengles"

RDEPEND="
	>=dev-cpp/gflags-2.0
	chromeos-base/libbrillo
	media-libs/libpng
	!opengles? ( virtual/opengl )
	opengles? ( virtual/opengles )
	x11-apps/xwd
"

DEPEND="
	${RDEPEND}
"

src_install() {
	dobin "${OUT}"/glbench
	dobin "${OUT}"/synccontroltest
	dobin "${OUT}"/teartest
	dobin "${OUT}"/windowmanagertest

	insinto /usr/share/glbench
	doins glbench_reference_images.txt
	doins glbench_knownbad_images.txt
	doins image.yuv
}
