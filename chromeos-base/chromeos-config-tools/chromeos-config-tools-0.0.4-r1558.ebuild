# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="00d2746d61903d8ab03e2648be8a47ad4f618611"
CROS_WORKON_TREE=("e689450ad3b8a87c3519bc7575b9504001dea652" "e8aa40363efa4179a7a6bdb8d7ea3a90e3525ee0" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb" "5d802ce81cebedab25f80fc52fa708a7743b9298")
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