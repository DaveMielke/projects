# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="fe0428beb48be86b6d6f5af48ab2232c16b7edfa"
CROS_WORKON_TREE=("002caee8ca3d7e4d62832d5d0af29f55128e4379" "49d0c2895621e6c7816bd5420eaf94ec3a214d76" "cba1b0ffaecbbeaf663966b4cf04552d1a0dd30c")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk power_manager wimax_manager"

PLATFORM_SUBDIR="wimax_manager"

inherit cros-workon platform

DESCRIPTION="Chromium OS WiMAX Manager"
HOMEPAGE="http://dev.chromium.org/chromium-os/platform"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="gdmwimax"

RDEPEND="
	dev-libs/dbus-c++
	gdmwimax? (
		chromeos-base/libbrillo
		chromeos-base/metrics
		>=dev-libs/glib-2.30
		dev-libs/protobuf
		virtual/gdmwimax
	)
"

DEPEND="
	${RDEPEND}
	gdmwimax? ( chromeos-base/system_api )
"

src_install() {
	# Install D-Bus introspection XML files.
	insinto /usr/share/dbus-1/interfaces
	doins dbus_bindings/org.chromium.WiMaxManager*.xml

	# Install D-Bus client library.
	platform_install_dbus_client_lib

	# Skip the rest of the files unless USE=gdmwimax is specified.
	use gdmwimax || return 0

	# Install daemon executable.
	dosbin "${OUT}"/wimax-manager

	# Install WiMAX Manager default config file.
	insinto /usr/share/wimax-manager
	doins default.conf

	# Install upstart config file.
	insinto /etc/init
	doins wimax_manager.conf

	# Install D-Bus config file.
	insinto /etc/dbus-1/system.d
	doins dbus_bindings/org.chromium.WiMaxManager.conf
}

platform_pkg_test() {
	use gdmwimax || return 0

	platform_test "run" "${OUT}/wimax_manager_testrunner"
}
