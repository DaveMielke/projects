# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="86bcf17f5d3fce2ea2e6f4d21ef7ca3b5a393ed2"
CROS_WORKON_TREE=("97311a29606c6363522a181834b5fc5d02f433d5" "2b7b46ab1083cdcc8b17bd7f5b05ddff336b0559" "a6a31e23defebcb231d77055003ed413feefc1c4" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(acostinas): Remove when https://crbug.com/809389 is fixed.
CROS_WORKON_SUBTREE="arc/network common-mk system-proxy .gn"

PLATFORM_SUBDIR="system-proxy"

inherit cros-workon platform

DESCRIPTION="A daemon that provides authentication support for system services
and ARC apps behind an authenticated web proxy."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/system-proxy/"

LICENSE="BSD-Google"
SLOT="0/0"
KEYWORDS="*"

COMMON_DEPEND="
	chromeos-base/arc-networkd:=
	chromeos-base/minijail:=
	dev-libs/protobuf:=
	dev-libs/dbus-glib:=
	sys-apps/dbus:=
	net-misc/curl:=
"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}"

pkg_preinst() {
	enewuser "system-proxy"
	enewgroup "system-proxy"
}

src_install() {
	dosbin "${OUT}"/system_proxy
	dosbin "${OUT}"/system_proxy_worker

	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.SystemProxy.conf

	insinto /usr/share/dbus-1/system-services
	doins dbus/org.chromium.SystemProxy.service

	insinto /etc/init
	doins init/system-proxy.conf

	insinto /usr/share/policy
	newins seccomp/system-proxy-seccomp-"${ARCH}".policy system-proxy-seccomp.policy
	newins seccomp/system-proxy-worker-seccomp-"${ARCH}".policy system-proxy-worker-seccomp.policy
}

platform_pkg_test() {
	platform_test "run" "${OUT}/system-proxy_test"
}
