# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="904d60c5dd6bbb939983e365ee1eb39684a4d608"
CROS_WORKON_TREE="50b3225c82c7bff753b8f82995fa7cd5a247ed12"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME="third_party/autotest/files"

inherit cros-workon autotest

DESCRIPTION="Autotest server tests for Bluetooth"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/autotest/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

# Enable autotest by default.
IUSE="+autotest"

RDEPEND="
	!<chromeos-base/autotest-server-tests-0.0.2-r4126
"

SERVER_IUSE_TESTS="
	+tests_bluetooth_AdapterAdvSanity
	+tests_bluetooth_AdapterAudioLink
	+tests_bluetooth_AdapterAUSanity
	+tests_bluetooth_AdapterCLSanity
	+tests_bluetooth_AdapterLEAdvertising
	+tests_bluetooth_AdapterLEBetterTogether
	+tests_bluetooth_AdapterLEHIDSanity
	+tests_bluetooth_AdapterLESanity
	+tests_bluetooth_AdapterMDSanity
	+tests_bluetooth_AdapterMTBF
	+tests_bluetooth_AdapterPowerMeasure
	+tests_bluetooth_AdapterQuickSanity
	+tests_bluetooth_AdapterSASanity
	+tests_bluetooth_PeerUpdate
	+tests_bluetooth_AdapterSRSanity
"

IUSE_TESTS="${IUSE_TESTS}
	${SERVER_IUSE_TESTS}
"

IUSE="${IUSE} ${IUSE_TESTS}"

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
