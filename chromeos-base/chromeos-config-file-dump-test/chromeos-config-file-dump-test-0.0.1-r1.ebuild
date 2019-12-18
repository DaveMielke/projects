# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# This ebuild only cares about its own FILESDIR and ebuild file, so it tracks
# the canonical empty project.
CROS_WORKON_COMMIT="3a01873e59ec25ecb10d1b07ff9816e69f3bbfee"
CROS_WORKON_TREE="8ce164efd78fcb4a68e898d8c92c7579657a49b1"
CROS_WORKON_PROJECT="chromiumos/infra/build/empty-project"
CROS_WORKON_LOCALNAME="empty-project"

DESCRIPTION="Tests of Chromium OS-specific configuration installed files"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="generated_cros_config"

inherit cros-workon cros-unibuild

DEPEND="
	!generated_cros_config? ( chromeos-base/chromeos-config )
	generated_cros_config? ( chromeos-base/chromeos-config-bsp:= )
"

# @FUNCTION: _verify_file_dump
# @USAGE: [file-suffix]
# @INTERNAL
# @DESCRIPTION:
# Dumps the file list based on the script and verifies expected match.
#   $1: Optional file suffix
_verify_file_dump() {
	local suffix="$1"

	local expected_files="${SYSROOT}${CROS_CONFIG_TEST_DIR}/file_dump${suffix}.txt"
	local file_dump_script="${SYSROOT}${CROS_CONFIG_TEST_DIR}/file_dump${suffix}.sh"
	local actual_files="${WORKDIR}/file_dump${suffix}.txt"

	if [[ -e "${expected_files}" ]]; then
		("${file_dump_script}" > "${actual_files}")
		verify_file_match "${expected_files}" "${actual_files}"
	else
		elog "Expectation file ${expected_files} not found, skipping."
	fi
}

src_test() {
	# _verify_file_dump cannot be done in src_test of
	# chromeos-config / chromeos-config-bsp because the file list may contain
	# files installed by chromeos-config / chromeos-config-bsp.
	_verify_file_dump "" # No suffix for public files
	_verify_file_dump "-private"
}
