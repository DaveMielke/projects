# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT=("b789504a98e1c5f9a2597040c638913e14ab199b" "28e9684dad685c2aea977ddbfec0fa00d67469c8")
CROS_WORKON_TREE=("d3226948f619b2e2def7e8955a0453b6bc4d82d5" "96d42b7250a5d1776aec0584047de60edcaa5166")
CROS_WORKON_LOCALNAME=(
	"platform2"
	"platform/imageloader"
)
CROS_WORKON_PROJECT=(
	"chromiumos/platform2"
	"chromiumos/platform/imageloader"
)
CROS_WORKON_DESTDIR=(
	"${S}/platform2"
	"${S}/platform/imageloader"
)
PLATFORM_SUBDIR="imageloader"

inherit cros-workon platform user

DESCRIPTION="Allow mounting verified utility images"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="chromeos-base/libbrillo
	dev-libs/openssl"

DEPEND="${RDEPEND}
	chromeos-base/system_api"

src_unpack() {
	local s="${S}"
	platform_src_unpack
	# look in src/platform
	S="${s}/platform/imageloader"
}

src_install() {
	# Install seccomp policy file.
	insinto /opt/google/imageloader
	newins "seccomp/imageloader-seccomp-${ARCH}.policy" imageloader-seccomp.policy
	newins "seccomp/imageloader-helper-seccomp-${ARCH}.policy" imageloader-helper-seccomp.policy
	cd "${OUT}"
	dosbin imageloader
	cd "${S}"
	dosbin imageloader_wrapper
	insinto /etc/dbus-1/system.d
	doins dbus_permissions/org.chromium.ImageLoader.conf
	insinto /usr/share/dbus-1/system-services
	doins dbus_service/org.chromium.ImageLoader.service
	insinto /etc/init
	doins imageloader.conf
}

platform_pkg_test() {
	platform_test "run" "${OUT}/run_tests"
}

pkg_preinst() {
	enewuser "imageloaderd"
	enewgroup "imageloaderd"
}
