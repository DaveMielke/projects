# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="c8123fd2eaecdc280f375d67144f2019866fab16"
CROS_WORKON_TREE=("f089191a0d3d6b85e2d71b4dbba970e0fc4966e1" "e81ebd7a3fb917a2b8bf6329717e1f9c413ea327" "c95b7c2c34a5b6e497150c6d30abbd5a1928f3d4" "7e189936f29d145c4191ea147e48256c92fac75d" "6037021bb9f75279b5ee3e3a98f6ee1f637cc416" "a6f407634a997b5e8601eba92cf78ac91a286e85" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk libhwsec libtpmcrypto metrics tpm_manager trunks .gn"

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
	chromeos-base/metrics
	chromeos-base/minijail
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