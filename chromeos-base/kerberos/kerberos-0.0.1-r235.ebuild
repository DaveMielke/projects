# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="63b51b8b9202b3963c87df283f49d53cf961ba98"
CROS_WORKON_TREE=("825512278f3738ba8ac7c5f167aacd4677cfebf7" "1ed938290dd08fbf20b6ad852236dd7c79fd09e1" "377caa22e8416ce2388b9c099e85be393001947f" "e0419631c76bfadb1dee2bcda2c68d825087f3f9" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk kerberos libpasswordprovider metrics .gn"

PLATFORM_SUBDIR="kerberos"

inherit cros-workon platform user

DESCRIPTION="Requests and manages Kerberos tickets to enable Kerberos SSO"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/kerberos/"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="asan fuzzer"

COMMON_DEPEND="
	app-crypt/mit-krb5:=
	chromeos-base/libbrillo:=[asan?,fuzzer?]
	chromeos-base/libpasswordprovider:=
	>=chromeos-base/metrics-0.0.1-r3152:=
	chromeos-base/minijail:=
	dev-libs/protobuf:=
	sys-apps/dbus:=
"
RDEPEND="${COMMON_DEPEND}"
DEPEND="
	${COMMON_DEPEND}
	chromeos-base/protofiles:=
	chromeos-base/session_manager-client:=
	chromeos-base/system_api:=[fuzzer?]
"

pkg_setup() {
	# Has to be done in pkg_setup() instead of pkg_preinst() since
	# src_install() needs kerberosd.
	enewuser kerberosd
	enewgroup kerberosd
	enewuser kerberosd-exec
	enewgroup kerberosd-exec
	cros-workon_pkg_setup
}

src_install() {
	dosbin "${OUT}"/kerberosd

	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.Kerberos.conf

	insinto /usr/share/dbus-1/system-services
	doins dbus/org.chromium.Kerberos.service

	insinto /etc/init
	doins init/kerberosd.conf

	insinto /usr/share/policy
	newins seccomp/kerberosd-seccomp-"${ARCH}".policy kerberosd-seccomp.policy

	insinto /usr/share/cros/startup/process_management_policies
	doins setuid_restrictions/kerberosd_whitelist.txt

	# Create daemon store folder prototype, see
	# https://chromium.googlesource.com/chromiumos/docs/+/master/sandboxing.md#securely-mounting-cryptohome-daemon-store-folders
	local daemon_store="/etc/daemon-store/kerberosd"
	dodir "${daemon_store}"
	fperms 0770 "${daemon_store}"
	fowners kerberosd:kerberosd "${daemon_store}"

	platform_fuzzer_install "${S}/OWNERS" "${OUT}"/config_parser_fuzzer \
		--dict "${S}"/config_parser_fuzzer.dict || die
}

platform_pkg_test() {
	local tests=(
		kerberos_test
	)
	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}