# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="14f359acdb09efafe628cb4f778eef0cf8288857"
CROS_WORKON_TREE=("2b7b46ab1083cdcc8b17bd7f5b05ddff336b0559" "42c8eaa22e0cbad4dd5d66a40807ba742e75ab6d" "a5740b2711dd8cd3b508a15a4986fd55f6fa3c8c" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk permission_broker webserver .gn"

PLATFORM_SUBDIR="webserver"

inherit cros-workon platform user

DESCRIPTION="HTTP sever interface library"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/webserver/"
LICENSE="BSD-Google"
KEYWORDS="*"

RDEPEND="
	chromeos-base/permission_broker:=
	net-libs/libmicrohttpd:=
	!chromeos-base/libwebserv:=
"

DEPEND="
	${RDEPEND}
	chromeos-base/permission_broker-client:=
"

pkg_preinst() {
	# Create user and group for webservd.
	enewuser "webservd"
	enewgroup "webservd"
}

src_install() {
	insinto "/usr/$(get_libdir)/pkgconfig"
	local v
	for v in "${LIBCHROME_VERS[@]}"; do
		libwebserv/preinstall.sh "${OUT}" "${v}"
		dolib.so "${OUT}/lib/libwebserv-${v}.so"
		doins "${OUT}/lib/libwebserv-${v}.pc"
	done

	# Install header files from libwebserv
	insinto /usr/include/libwebserv
	doins libwebserv/*.h

	# Install init scripts for webservd.
	insinto /etc/init
	doins webservd/etc/init/webservd.conf

	# Install DBus configuration files.
	insinto /etc/dbus-1/system.d
	doins webservd/etc/dbus-1/org.chromium.WebServer.conf

	# Install seccomp filter for webservd.
	insinto /usr/share/filters
	doins webservd/usr/share/filters/webservd-seccomp.policy

	# Install web server daemon.
	dobin "${OUT}"/webservd
}

platform_pkg_test() {
	local tests=(
		libwebserv_testrunner
		webservd_testrunner
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
