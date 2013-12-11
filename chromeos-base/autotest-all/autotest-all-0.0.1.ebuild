# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit cros-constants


DESCRIPTION="Meta ebuild for all packages providing tests"
HOMEPAGE="http://www.chromium.org"

LICENSE="GPL-2"
SLOT=0
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE=""

RDEPEND="
	chromeos-base/autotest-client
	chromeos-base/autotest-tests
	chromeos-base/autotest-tests-ibus
	chromeos-base/autotest-tests-ltp
	chromeos-base/autotest-tests-ownershipapi
	chromeos-base/autotest-tests-touchpad
	chromeos-base/autotest-chrome
	chromeos-base/autotest-factory
	chromeos-base/autotest-factory-install
	chromeos-base/autotest-private-all
"

DEPEND="${RDEPEND}"

SUITE_DEPENDENCIES_FILE="dependency_info"
SUITE_TO_CONTROL_MAP="suite_to_control_file_map"

src_unpack() {
	elog "Unpacking..."
	mkdir -p "${S}"
	touch "${S}/${SUITE_DEPENDENCIES_FILE}"
	touch "${S}/${SUITE_TO_CONTROL_MAP}"
}

src_install() {
	# So that this package properly owns the file
	insinto ${AUTOTEST_BASE}/test_suites
	doins "${SUITE_DEPENDENCIES_FILE}"
	doins "${SUITE_TO_CONTROL_MAP}"
}

# Pre-processes control files and installs DEPENDENCIES info.
pkg_postinst() {
	local root_autotest_dir="${ROOT}${AUTOTEST_BASE}"
	python -B "${root_autotest_dir}/site_utils/suite_preprocessor.py" \
		-a "${root_autotest_dir}" \
		-o "${root_autotest_dir}/test_suites/${SUITE_DEPENDENCIES_FILE}"
	python -B "${root_autotest_dir}/site_utils/control_file_preprocessor.py" \
		-a "${root_autotest_dir}" \
		-o "${root_autotest_dir}/test_suites/${SUITE_TO_CONTROL_MAP}"
}
