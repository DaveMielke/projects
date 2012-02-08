# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=2
CROS_WORKON_COMMIT="5da7035bf5effbd1fb5e43b13f8a44fca954720c"
CROS_WORKON_PROJECT="chromiumos/platform/gobi-cromo-plugin"
CROS_WORKON_USE_VCSID="1"

inherit cros-debug cros-workon toolchain-funcs multilib

DESCRIPTION="Cromo plugin to control Qualcomm Gobi modems"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="install_tests"

RDEPEND="chromeos-base/cromo
	chromeos-base/gobi-sdk
	chromeos-base/libchrome:0
	dev-cpp/glog
	dev-libs/dbus-c++
	chromeos-base/metrics
	chromeos-base/gobi3k-sdk
	chromeos-base/gobi3k-lib
	install_tests? ( dev-cpp/gmock dev-cpp/gtest )
"
DEPEND="${RDEPEND}
	dev-cpp/gmock
	dev-cpp/gtest
	net-misc/modemmanager
"

cr_make() {
	emake \
		LIBDIR=/usr/$(get_libdir) \
		$(use install_tests && echo INSTALL_TESTS=1) \
		"$@" || die

}

src_compile() {
	tc-export CXX LD CC
	cros-debug-add-NDEBUG
	cr_make
}

mkqcqmirules() {
	rule="ACTION==\"add|change\", SUBSYSTEM==\"QCQMI\", KERNEL==\"qcqmi[0-9]*\""
	rule="$rule, OWNER=\"cromo\""
	rule="$rule, GROUP=\"cromo\""
	echo "$rule"
}

src_install() {
	cr_make DESTDIR="${D}" install
	# The qualcomm makefile for gobi-cromo-plugin seems to stick its own
	# rules into this directory, which I don't think is right - I believe
	# /lib/udev/rules.d belongs to udev and /etc/udev/rules.d is for distro
	# stuff. Ah well.
	mkqcqmirules > "${D}/lib/udev/rules.d/76-cromo-gobi-permissions.rules"
}
