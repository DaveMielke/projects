# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="b733c2848a803e1b9a6fd4a71cf94edf76e98be5"
CROS_WORKON_TREE=("e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb" "c920da127f686c434165b6056b1cd740f228df6b" "201db92dbc5645d9a9fb9b33e26a0e669f52577d" "85dcd31292e99125b2eb2744c83442e00dece79f" "824835433089136b9e63f6cfd441ed8c093fa54c")
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="../platform2"
CROS_WORKON_SUBTREE=".gn camera/build camera/common camera/include common-mk"
CROS_WORKON_OUTOFTREE_BUILD="1"
CROS_WORKON_INCREMENTAL_BUILD="1"

PLATFORM_SUBDIR="camera/common/libcamera_timezone"

inherit cros-camera cros-workon platform

DESCRIPTION="Chrome OS camera HAL Time zone util."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="!media-libs/arc-camera3-libcamera_timezone"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_install() {
	platform_src_install
	dolib.so "${OUT}/lib/libcamera_timezone.so"

	cros-camera_doheader ../../include/cros-camera/timezone.h

	cros-camera_dopc ../libcamera_timezone.pc.template
}