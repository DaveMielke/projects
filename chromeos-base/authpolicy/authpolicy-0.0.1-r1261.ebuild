# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="97957b865770ea7caf76d1e8ff81d979aee45d2e"
CROS_WORKON_TREE=("32846ae6bc5a87e046276856720e89529dda1626" "ed20839a6df3ad03a201c16b460608c2a3770fcb" "bb1e0b651b26e8442a744c61ed7633d032dac607" "dc1506ef7c8cfd2c5ffd1809dac05596ec18773c")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk authpolicy metrics .gn"

PLATFORM_SUBDIR="authpolicy"

inherit cros-workon platform user

DESCRIPTION="Provides authentication to LDAP and fetching device/user policies"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="+samba asan fuzzer"

RDEPEND="
	app-crypt/mit-krb5
	chromeos-base/libbrillo[asan?,fuzzer?]
	chromeos-base/metrics
	>=chromeos-base/minijail-0.0.1-r1477
	dev-libs/protobuf:=
	dev-libs/dbus-glib
	samba? ( >=net-fs/samba-4.5.3-r6 )
	sys-apps/dbus
	sys-libs/libcap
"
DEPEND="
	${RDEPEND}
	chromeos-base/cryptohome-client
	chromeos-base/protofiles:=
	chromeos-base/session_manager-client
	chromeos-base/system_api
"

pkg_setup() {
	enewuser "authpolicyd"
	enewgroup "authpolicyd"
	enewuser "authpolicyd-exec"
	enewgroup "authpolicyd-exec"
	cros-workon_pkg_setup
}

src_install() {
	dosbin "${OUT}"/authpolicyd
	dosbin "${OUT}"/authpolicy_parser
	insinto /etc/dbus-1/system.d
	doins etc/dbus-1/org.chromium.AuthPolicy.conf
	insinto /etc/init
	doins etc/init/authpolicyd.conf
	insinto /usr/share/policy
	doins seccomp_filters/*.policy
	insinto /usr/share/cros/startup/process_management_policies
	doins setuid_restrictions/authpolicyd_whitelist.txt

	# Create daemon store folder prototype, see
	# https://chromium.googlesource.com/chromiumos/docs/+/master/sandboxing.md#securely-mounting-cryptohome-daemon-store-folders
	local daemon_store="/etc/daemon-store/authpolicyd"
	dodir "${daemon_store}"
	fperms 0700 "${daemon_store}"
	fowners authpolicyd:authpolicyd "${daemon_store}"

	platform_fuzzer_install "${S}"/OWNERS "${OUT}"/preg_parser_fuzzer \
		--seed_corpus "${S}"/policy/testdata/preg_parser_fuzzer_seed_corpus.zip \
		--dict "${S}"/policy/testdata/preg_parser_fuzzer.dict
}

platform_pkg_test() {
	local tests=(
		authpolicy_test
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done

	platform_fuzzer_test "${OUT}"/preg_parser_fuzzer
}
