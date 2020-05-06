# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="4332c7b0d5e5da36ae72e29a22d78afbd392b9f7"
CROS_WORKON_TREE="11e321cf10f2a38f1ca940cc824528a5de4018bc"
CROS_WORKON_PROJECT="chromiumos/third_party/aver-updater"

inherit cros-workon libchrome udev user

DESCRIPTION="AVer firmware updater"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/aver-updater"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	chromeos-base/libbrillo:=
"

src_configure() {
	# Disable tautological-compare warnings, crbug.com/1042142
	append-cppflags "-Wno-tautological-compare"
	# Needed since libchrome includes cros-debug
	cros-debug-add-NDEBUG
	default
}

src_install() {
	dosbin aver-updater
	udev_dorules conf/99-run-aver-updater.rules
}

pkg_preinst() {
	enewuser cfm-firmware-updaters
	enewgroup cfm-firmware-updaters
}
