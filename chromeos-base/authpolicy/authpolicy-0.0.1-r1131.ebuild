# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="15e429ab7d79d4737cfdd849a616363faf4a239d"
CROS_WORKON_TREE=("ce3911c93fc604a2c44c1878633891218a2c3f1b" "0cc77cfd2954600876f1b331deba3b412ceaeaae" "f16df4fd11ad50362ec1284570a96653b2e14faf")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk authpolicy metrics"

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
	dev-libs/protobuf
	dev-libs/dbus-glib
	samba? ( >=net-fs/samba-4.5.3-r6 )
	sys-apps/dbus
	sys-libs/libcap
"
DEPEND="
	${RDEPEND}
	chromeos-base/protofiles:=
	chromeos-base/system_api
"

pkg_preinst() {
	# Create user and group for authpolicyd and authpolicyd-exec.
	enewuser "authpolicyd"
	enewgroup "authpolicyd"
	enewuser "authpolicyd-exec"
	enewgroup "authpolicyd-exec"
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
