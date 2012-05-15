# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_PROJECT="chromiumos/platform/wimax_manager"

inherit toolchain-funcs cros-debug cros-workon

DESCRIPTION="Chromium OS WiMAX Manager"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="gdmwimax test"

LIBCHROME_VERS="125070"

RDEPEND="gdmwimax? (
	chromeos-base/libchromeos
	chromeos-base/metrics
	dev-cpp/gflags
	dev-libs/dbus-c++
	>=dev-libs/glib-2.30
)"

DEPEND="gdmwimax? (
	${RDEPEND}
	chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	net-wireless/gdmwimax
	test? ( dev-cpp/gmock )
	test? ( dev-cpp/gtest )
)"

src_compile() {
	if use gdmwimax; then
		tc-export CXX CC OBJCOPY PKG_CONFIG STRIP
		cros-debug-add-NDEBUG
		emake OUT=build-opt BASE_VER=${LIBCHROME_VERS}
	fi
}

src_test() {
	if use gdmwimax; then
		emake OUT=build-opt BASE_VER=${LIBCHROME_VERS} tests
	fi
}

src_install() {
	if use gdmwimax; then
		# Install daemon executable.
		dosbin build-opt/wimax-manager

		# Install upstart config file.
		insinto /etc/init
		doins wimax_manager.conf

		# Install D-Bus config file.
		insinto /etc/dbus-1/system.d
		doins dbus_bindings/org.chromium.WiMaxManager.conf
	fi

	# Install D-Bus introspection XML files.
	insinto /usr/share/dbus-1/interfaces
	doins dbus_bindings/org.chromium.WiMaxManager*.xml
}
