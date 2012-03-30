# Copyright (C) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE.makefile file.

EAPI=2
CROS_WORKON_COMMIT="244e558593d111ac8624ede17452c4fdb8bbd160"
CROS_WORKON_PROJECT="chromiumos/platform/chaps"

KEYWORDS="arm amd64 x86"

inherit toolchain-funcs cros-debug cros-workon

DESCRIPTION="PKCS #11 layer over TrouSerS."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
IUSE="test"

RDEPEND="
	app-crypt/trousers
	chromeos-base/chromeos-init
	chromeos-base/libchrome:85268[cros-debug=]
	chromeos-base/libchromeos
	dev-libs/dbus-c++
	dev-libs/opencryptoki
	dev-cpp/gflags"

DEPEND="${RDEPEND}
	dev-cpp/gmock
	test? ( dev-cpp/gtest )
	dev-db/leveldb"

CROS_WORKON_LOCALNAME="$(basename ${CROS_WORKON_PROJECT})"

src_compile() {
	tc-export CXX OBJCOPY PKG_CONFIG STRIP
	cros-debug-add-NDEBUG
	emake all || die "failed to make chaps"
}

src_test() {
	cros-debug-add-NDEBUG
	emake tests || die "failed to make chaps tests"
	emake runtests || die "failed to run chaps tests"
}

src_install() {
	dosbin build-opt/chapsd || die
	dobin build-opt/p11_replay || die
	dolib.so build-opt/libchaps.so || die
	# Install D-Bus config file.
	insinto /etc/dbus-1/system.d
	doins org.chromium.Chaps.conf || die
	# Install D-Bus service file.
	insinto /usr/share/dbus-1/services
	doins org.chromium.Chaps.service || die
	# Install upstart config file.
	insinto /etc/init
	doins chapsd.conf || die
	# Install headers for use by clients.
	insinto /usr/include/chaps
	doins login_event_client.h || die
}

