# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="3c24751e7b54732387b6da5896a990a12a870e65"
CROS_WORKON_TREE=("3f47c000ac2656a574bb06b430a66f6783c3842a" "f8426420f9b1a0a0213cbe233da8f160d6b5ec8a" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_SUBTREE="common-mk cfm-dfu-notification .gn"
CROS_WORKON_DESTDIR="${S}/platform2"

PLATFORM_SUBDIR="cfm-dfu-notification"

inherit cros-workon platform

DESCRIPTION="Library to send firmware update notifications to CFM"

LICENSE="BSD-Google"
SLOT="0/0"
KEYWORDS="*"

RDEPEND=""
DEPEND="${RDEPEND}"

src_install() {
	dolib.so "${OUT}"/lib/libcfm_dfu_notification.so

	"${S}"/platform2_preinstall.sh "${PV}" "/usr/include/chromeos" "${OUT}"
	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${OUT}"/cfm-dfu-notification.pc

	insinto "/usr/include/chromeos/cfm-dfu-notification"
	doins ./*.h
}

platform_pkg_test() {
	platform_test "run" "${OUT}"/cfm_dfu_notification_test
}