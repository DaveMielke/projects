# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT=("44c34946304cef80bc0335e3bd941b6b77dad83e" "0b071fa376483223c933d29b60655741742bb28b")
CROS_WORKON_TREE=("cad58bc82a7e34a78fb8fdcde89a3d815526b756" "6589055d0d41e7fc58d42616ba5075408d810f7d" "dd7b531bcc36c54ee65673301b41e299b76731fc")
CROS_WORKON_PROJECT=(
	"chromiumos/platform/arc-camera"
	"chromiumos/platform2"
)
CROS_WORKON_LOCALNAME=(
	"../platform/arc-camera"
	"../platform2"
)
CROS_WORKON_DESTDIR=(
	"${S}/platform/arc-camera"
	"${S}/platform2"
)
CROS_WORKON_SUBTREE=(
	"hal/usb_v1 build"
	"common-mk"
)
PLATFORM_GYP_FILE="hal/usb_v1/arc_camera_service.gyp"

inherit cros-workon platform user

DESCRIPTION="ARC camera service. The service is in charge of accessing camera
device. It uses linux domain socket (/run/camera/camera.sock) to build a
synchronous channel."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"

RDEPEND="!chromeos-base/arc-camera-service"

DEPEND="${RDEPEND}
	chromeos-base/libbrillo
	chromeos-base/libmojo
	virtual/pkgconfig"

src_unpack() {
	local s="${S}"
	platform_src_unpack
	# look in src/platform/arc-camera
	S="${s}/platform/arc-camera"
}

src_install() {
	dobin "${OUT}/arc_camera_service"

	insinto /etc/init
	doins hal/usb_v1/init/arc-camera.conf
}

pkg_preinst() {
	enewuser "arc-camera"
	enewgroup "arc-camera"
}
