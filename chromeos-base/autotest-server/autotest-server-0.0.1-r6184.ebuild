# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="84b8aa468ab52b1ac7b2005d4ac80b5dfaf918ce"
CROS_WORKON_TREE="1f8e2e716495641812b8729f74aca8469e48c630"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest/files

inherit cros-workon cros-constants

DESCRIPTION="Autotest scripts and tools"
HOMEPAGE="http://dev.chromium.org/chromium-os/testing"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	chromeos-base/autotest-server-deps
	chromeos-base/autotest-web-frontend
	chromeos-base/infra-virtualenv
	chromeos-base/lucifer
	chromeos-base/tast-cmd
	chromeos-base/tast-remote-tests-cros
"

DEPEND=""

AUTOTEST_WORK="${WORKDIR}/autotest-work"
AUTOTEST_BASE="/autotest"

src_prepare() {
	default
	mkdir -p "${AUTOTEST_WORK}"
	rsync -am --exclude="*.pyc" --exclude="server/site_tests" --exclude="server/tests" \
		--exclude="client/site_tests" --exclude="client/tests" \
		"${S}"/* "${AUTOTEST_WORK}/" || die "Failed to copy autotest source code"

	local test_to_copy=('provision_AutoUpdate' 'hardware_StorageQualCheckSetup')

	for test in "${test_to_copy[@]}"; do
		rsync -am "${S}"/server/site_tests/"${test}" \
			"${AUTOTEST_WORK}/"server/site_tests/ || die "Failed to copy ${test} tests"
	done

	rm -f "${AUTOTEST_WORK}"/shadow_config.ini || die
	# We want to create a symlink here instead.
	rm -rf "${AUTOTEST_WORK}"/logs || die

	mkdir -p "${AUTOTEST_WORK}"/server/tests || die
}

src_compile() {
	protoc --proto_path "${S}" --python_out="${AUTOTEST_WORK}" "${S}/tko/tko.proto"
	protoc --proto_path "${S}" --python_out="${AUTOTEST_WORK}" "${S}/site_utils/cloud_console.proto"
}

src_configure() {
	cros-workon_src_configure
}

src_install() {
	insinto "${AUTOTEST_BASE}"
	doins -r "${AUTOTEST_WORK}"/*
	chmod a+x "${D}/${AUTOTEST_BASE}"/tko/*.cgi

	dosym /var/log/autotest "${AUTOTEST_BASE}"/logs
}

src_test() {
	# Run the autotest unit tests.
	./utils/unittest_suite.py --debug || die "Autotest unit tests failed."
}
