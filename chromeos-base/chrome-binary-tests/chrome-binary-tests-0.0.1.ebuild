# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Install Chromium binary tests to test image"
HOMEPAGE="http://www.chromium.org"
SRC_URI=""

LICENSE="BSD-Google"

SLOT="0"
KEYWORDS="*"
S="${WORKDIR}"

DEPEND="chromeos-base/chromeos-chrome"

src_install() {
	exeinto /usr/libexec/chrome-binary-tests
	# The binary tests in ${BINARY_DIR} are built by chrome-chrome.
	BINARY_DIR="${SYSROOT}/usr/local/build/autotest/client/deps/chrome_test/test_src/out/Release"
	doexe "${BINARY_DIR}/capture_unittests"
	doexe "${BINARY_DIR}/jpeg_decode_accelerator_unittest"
	doexe "${BINARY_DIR}/jpeg_encode_accelerator_unittest"
	doexe "${BINARY_DIR}/ozone_gl_unittests"
	doexe "${BINARY_DIR}/sandbox_linux_unittests"
	# TODO(crbug.com/879065): After video_decode_accelerator_tests gets
	# enough functionalities to replace video_decode_accelerator_unittest
	# with, remove video_decode_accelerator_unittest.
	doexe "${BINARY_DIR}/video_decode_accelerator_tests"
	doexe "${BINARY_DIR}/video_decode_accelerator_unittest"
	doexe "${BINARY_DIR}/video_encode_accelerator_unittest"
	doexe "${BINARY_DIR}/wayland_client_perftests"
}
