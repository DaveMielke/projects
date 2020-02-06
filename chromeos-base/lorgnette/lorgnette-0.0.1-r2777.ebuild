# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="2f3192515137008a7ecfed5b22ede2cf34e8f7d7"
CROS_WORKON_TREE=("2ef18d1c42c7aee2c4bb4110359103045c055adf" "8da2393f085e7e7f6803235e2e6517ff8bc7ce3d" "11cf580b60e9b5b8fdc05216e8ff2e2f29622168" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk lorgnette metrics .gn"

PLATFORM_SUBDIR="lorgnette"

inherit cros-workon platform

DESCRIPTION="Document Scanning service for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
KEYWORDS="*"
IUSE=""

COMMON_DEPEND="
	chromeos-base/minijail:=
	chromeos-base/metrics:=
"

RDEPEND="${COMMON_DEPEND}
	media-gfx/sane-backends:=
	media-gfx/pnm2png:=
"

DEPEND="${COMMON_DEPEND}
	chromeos-base/permission_broker-client:=
	chromeos-base/system_api:=
"

src_install() {
	dobin "${OUT}"/lorgnette
	insinto /etc/dbus-1/system.d
	doins dbus_permissions/org.chromium.lorgnette.conf
	insinto /usr/share/dbus-1/system-services
	doins dbus_service/org.chromium.lorgnette.service
}

platform_pkg_test() {
	platform_test "run" "${OUT}/lorgnette_unittest"
}
