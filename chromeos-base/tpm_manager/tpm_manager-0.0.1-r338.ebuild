# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("5d3b89ed6431d871b90719dc9336e227e29c6bf2" "655d35e67b7cf5c0ea273de8a9bb2606476e53f8")
CROS_WORKON_TREE=("2d9529cd2fe6509893f8cdde1f9e5e687f3e3eb5" "7fb579ffcb399b285209f10ba698bdd496d18bb0")
CROS_WORKON_BLACKLIST=1
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/aosp/system/tpm")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME=("platform2" "aosp/system/tpm")
CROS_WORKON_PROJECT=("chromiumos/platform2" "platform/system/tpm")
CROS_WORKON_REPO=("https://chromium.googlesource.com" "https://android.googlesource.com")
CROS_WORKON_USE_VCSID=1

PLATFORM_SUBDIR="tpm_manager"

inherit cros-workon platform user

DESCRIPTION="Daemon to manage TPM ownership."
HOMEPAGE="http://www.chromium.org/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="test -tpm2"

RDEPEND="
	!tpm2? (
		app-crypt/trousers
	)
	tpm2? (
		chromeos-base/trunks
	)
	chromeos-base/chromeos-minijail
	chromeos-base/libbrillo
	"

DEPEND="
	${RDEPEND}
	test? ( dev-cpp/gmock )
	dev-cpp/gtest
	"

pkg_preinst() {
	enewuser tpm_manager
	enewgroup tpm_manager
}

src_unpack() {
	local s="${S}"
	platform_src_unpack
	S="${s}/aosp/system/tpm/tpm_manager"
}

src_install() {
	# Install D-Bus configuration file.
	insinto /etc/dbus-1/system.d
	doins server/org.chromium.TpmManager.conf

	# Install upstart config file.
	insinto /etc/init
	doins server/tpm_managerd.conf

	# Install the executables provided by TpmManager
	dosbin "${OUT}"/tpm_managerd
	dobin "${OUT}"/tpm_manager_client
	dolib.so "${OUT}"/lib/libtpm_manager.so

	# Install seccomp policy files.
	insinto /usr/share/policy
	newins server/tpm_manager-seccomp-${ARCH}.policy tpm_managerd-seccomp.policy

	# Install header files.
	insinto /usr/include/tpm_manager/tpm_manager_client
	doins client/tpm_nvram_dbus_proxy.h
	doins client/tpm_ownership_dbus_proxy.h
	insinto /usr/include/tpm_manager/common
	doins common/export.h
	doins common/tpm_manager_constants.h
	doins common/tpm_nvram_interface.h
	doins common/tpm_ownership_interface.h
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
