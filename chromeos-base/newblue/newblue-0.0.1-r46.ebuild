# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=5
CROS_WORKON_COMMIT="0654a808ba3e317ff5ed6a27e6ef1d775b81ddff"
CROS_WORKON_TREE="c6e5a35a817b691e54e29a97258a8346d60d2704"
CROS_WORKON_PROJECT="chromiumos/platform/newblue"
CROS_WORKON_LOCALNAME="newblue"
CROS_WORKON_INCREMENTAL_BUILD=1

inherit toolchain-funcs multilib cros-workon udev

DESCRIPTION="NewBlue Bluetooth stack"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/newblue"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

src_configure() {
	cros-workon_src_configure
}

src_test() {
	if ! use x86 && ! use amd64 ; then
		elog "Skipping unit tests on non-x86 platform"
	elif [[ $(get-flag march) == amd* ]]; then
		# SSE4a optimization causes tests to not run properly on Intel bots.
		# https://crbug.com/856686
		elog "Skipping unit tests on AMD platform"
	else
		emake test
	fi
}

src_install() {
	emake DESTDIR="${D}" libdir=/usr/"$(get_libdir)" install

	insinto /usr/"$(get_libdir)"/pkgconfig
	doins newblue.pc

	udev_dorules "${FILESDIR}"/50-newblue.rules
}
