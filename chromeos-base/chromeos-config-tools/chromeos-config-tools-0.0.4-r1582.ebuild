# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="eadbb5017b350aba87d4bd5a2931885bc2bf2a56"
CROS_WORKON_TREE=("1c07dc76ec4881aeccc6c6151786dc26bf5f73c0" "0cb68e923b1ad6eeb3f9e64264da4ea605ab6225" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb" "e9a9bc3e1cdbf37b0942836fa7610b0d35907581")
CROS_WORKON_INCREMENTAL_BUILD=1

CROS_WORKON_PROJECT=(
	"chromiumos/platform2"
)
CROS_WORKON_LOCALNAME=(
	"platform2"
)
CROS_WORKON_SUBTREE=(
	"common-mk chromeos-config .gn power_manager"
)
CROS_WORKON_DESTDIR=(
	"${S}/platform2"
)
PLATFORM_SUBDIR="chromeos-config"

inherit cros-workon platform

DESCRIPTION="Chrome OS configuration tools"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/chromeos-config"

LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}"

src_install() {
	dolib.so "${OUT}/lib/libcros_config.so"

	insinto "/usr/include/chromeos/chromeos-config/libcros_config"
	doins "${S}"/libcros_config/*.h

	"${S}"/platform2_preinstall.sh "${PV}" "/usr/include/chromeos" "${OUT}"
	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${OUT}"/libcros_config.pc

	insinto "/usr/include/cros_config"
	doins "libcros_config/cros_config_interface.h"
	doins "libcros_config/cros_config.h"
	doins "libcros_config/fake_cros_config.h"

	dobin "${OUT}"/cros_config
	newbin cros_config_mock.sh cros_config_mock
	dosbin "${OUT}"/cros_configfs

	# Install init scripts.
	insinto /etc/init
	doins init/*.conf
}

platform_pkg_test() {
	# Run this here since we may not run cros_config_main_test.
	./chromeos-config-test-setup.sh
	local tests=(
		fake_cros_config_test
		cros_config_test
		cros_config_main_test
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
	./run_tests.sh || die "cros_config unit tests have errors"
}