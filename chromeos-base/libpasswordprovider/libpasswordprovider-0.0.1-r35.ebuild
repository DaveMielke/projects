# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="c12468e63c2a2e704436d23a5a66abad80024d61"
CROS_WORKON_TREE="3e20b8082cb3c004a43bea11312ee4dd50bbc63b"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
PLATFORM_SUBDIR="libpasswordprovider"

inherit cros-workon platform

DESCRIPTION="Library for storing and retrieving user password"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/libpasswordprovider"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	chromeos-base/libbrillo
"

DEPEND="${RDEPEND}"

src_install() {
	dolib.so "${OUT}/lib/libpasswordprovider.so"

	insinto "/usr/$(get_libdir)/pkgconfig"
	doins libpasswordprovider.pc

	insinto "/usr/include/libpasswordprovider"
	doins *.h
}

platform_pkg_test() {

	platform_test "run" "${OUT}/${test_bin}" "0" "${gtest_filter}"
}

platform_pkg_test() {
	local gtest_filter=""
	if ! use x86 && ! use amd64 ; then
		# PasswordProvider tests fail on qemu due to unsupported system calls to keyrings.
		# Run only the Password unit tests on qemu since keyrings are not supported yet.
		# https://crbug.com/792699
		einfo "Skipping PasswordProvider unit tests on non-x86 platform"
		gtest_filter+="Password.*"
	fi

	local tests=(
		password_provider_test
	)

	local test_bin
		for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}" 0 "${gtest_filter}"
	done
}
