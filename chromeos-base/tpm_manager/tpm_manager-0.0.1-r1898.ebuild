# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="e835325abfa6acfee13582dbdf2c779708818ff9"
CROS_WORKON_TREE=("bfa2dfdfdc1fd669d4e14dc30d8f0fc82490bad9" "38a36f76290e3e0f13d021ad8597ea5f250a05ba" "e0e2a108a7c4b5075717490bf1d7c0823437c045" "4aa72d025149303c5db01a50621f57e8a131f6a4" "26c78fd15c90622d10d92f30cdc76cf7db4fb266" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk libhwsec libtpmcrypto tpm_manager trunks .gn"

PLATFORM_SUBDIR="tpm_manager"

inherit cros-workon platform user

DESCRIPTION="Daemon to manage TPM ownership."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/tpm_manager/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="distributed_cryptohome test tpm tpm2"

REQUIRED_USE="tpm2? ( !tpm )"

RDEPEND="
	!tpm2? ( app-crypt/trousers )
	tpm2? (
		chromeos-base/trunks
	)
	chromeos-base/minijail
	chromeos-base/libbrillo
	chromeos-base/libhwsec
	chromeos-base/libtpmcrypto
	"

DEPEND="${RDEPEND}
	tpm2? ( chromeos-base/trunks[test?] )
	"

pkg_preinst() {
	enewuser tpm_manager
	enewgroup tpm_manager
}

src_install() {
	# Install D-Bus configuration file.
	if use tpm2 || use distributed_cryptohome; then
		insinto /etc/dbus-1/system.d
		doins server/org.chromium.TpmManager.conf

		# Install upstart config file.
		insinto /etc/init
		doins server/tpm_managerd.conf
		if use tpm2; then
			sed -i 's/started tcsd/started trunksd/' \
				"${D}/etc/init/tpm_managerd.conf" ||
				die "Can't replace tcsd with trunksd in tpm_managerd.conf"
		fi

		# Install the executables provided by TpmManager
		dosbin "${OUT}"/tpm_managerd
		dosbin "${OUT}"/local_data_migration
		dobin "${OUT}"/tpm_manager_client

		# Install seccomp policy files.
		insinto /usr/share/policy
		newins server/tpm_managerd-seccomp-${ARCH}.policy tpm_managerd-seccomp.policy
	fi

	dolib.so "${OUT}"/lib/libtpm_manager.so
	dolib.a "${OUT}"/libtpm_manager_test.a


	# Install header files.
	insinto /usr/include/tpm_manager/client
	doins client/*.h
	insinto /usr/include/tpm_manager/common
	doins common/*.h
}

platform_pkg_test() {
	local tests=(
		tpm_manager_testrunner
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
