# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="2727fbc11987f9d0ccc2635e033e204fc6986239"
CROS_WORKON_TREE=("e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb" "d58be6324ba2a1d0452d23bafb39c869c5ed2cd6" "1a726887830cbec8816758211b4a4def770caaa3" "4cc600d625ecfdac13d984d9190d63a8970b0a4b" "f8af72338aabb6766a39a3a323624a050d01d159")
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="../platform2"
CROS_WORKON_SUBTREE=".gn camera/build camera/common camera/include common-mk"
CROS_WORKON_OUTOFTREE_BUILD="1"
CROS_WORKON_INCREMENTAL_BUILD="1"

PLATFORM_SUBDIR="camera/common/libcamera_exif"

inherit cros-camera cros-workon platform

DESCRIPTION="Chrome OS camera HAL exif util."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	!media-libs/arc-camera3-libcamera_exif
	media-libs/libexif"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_install() {
	platform_src_install
	dolib.so "${OUT}/lib/libcamera_exif.so"

	cros-camera_doheader ../../include/cros-camera/exif_utils.h

	cros-camera_dopc ../libcamera_exif.pc.template
}