# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="c6e430949b7789fd1155da1ce6451cc5c30f2555"
CROS_WORKON_TREE=("3ec7544c4b108a15d3ea61facc0a4bbeace58eed" "511b26c4b13232121a9e3e48d157cf1706097a23" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"
CROS_WORKON_SUBTREE="common-mk libchromeos-ui .gn"

PLATFORM_NATIVE_TEST="yes"
PLATFORM_SUBDIR="libchromeos-ui"

inherit cros-workon platform

DESCRIPTION="Library used to start Chromium-based UIs"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	chromeos-base/bootstat
	chromeos-base/libbrillo
	"

DEPEND="${RDEPEND}"

src_install() {
	local v

	insinto "/usr/$(get_libdir)/pkgconfig"
	for v in "${LIBCHROME_VERS[@]}"; do
		./platform2_preinstall.sh "${OUT}" "${v}"
		dolib.so "${OUT}"/lib/libchromeos-ui-"${v}".so
		doins "${OUT}"/lib/libchromeos-ui-"${v}".pc
	done

	insinto /usr/include/chromeos/ui
	doins "${S}"/chromeos/ui/*.h
}

platform_pkg_test() {
	platform_test "run" "${OUT}/libchromeos-ui-test"
}
