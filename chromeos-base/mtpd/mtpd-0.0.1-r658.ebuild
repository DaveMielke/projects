# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="a504beb965b11ae4849d2c063cd9cc225dbce5bb"
CROS_WORKON_TREE=("3cce98a421bc990c08ef9bb34aab72cd5547810d" "1197a488503e9e50eb5e9d3e5c24c328182a99d8" "dc1506ef7c8cfd2c5ffd1809dac05596ec18773c")
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_SUBTREE="common-mk mtpd .gn"
PLATFORM_SUBDIR="mtpd"
PLATFORM_NATIVE_TEST="yes"

inherit cros-workon platform systemd user

DESCRIPTION="MTP daemon for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/mtpd"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan +seccomp systemd test"

RDEPEND="
	chromeos-base/libbrillo
	dev-libs/protobuf:=
	media-libs/libmtp
	virtual/udev
"

DEPEND="${RDEPEND}
	chromeos-base/system_api"

src_install() {
	exeinto /opt/google/mtpd
	doexe "${OUT}"/mtpd

	# Install seccomp policy file.
	insinto /opt/google/mtpd
	use seccomp && newins "mtpd-seccomp-${ARCH}.policy" mtpd-seccomp.policy

	# Install the init scripts.
	if use systemd; then
		systemd_dounit mtpd.service
		systemd_enable_service system-services.target mtpd.service
	else
		insinto /etc/init
		doins mtpd.conf
	fi

	# Install D-Bus config file.
	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.Mtpd.conf
}

platform_pkg_test() {
	platform_test "run" "${OUT}/mtpd_testrunner"
}

pkg_preinst() {
	enewuser "mtp"
	enewgroup "mtp"
}
