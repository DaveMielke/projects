# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="c93815c3844f5a1a4f2386c0ba943da663f6db8f"
CROS_WORKON_TREE="c3bf1ca0fed36231d19c580814a45d7a07be5ff5"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest/files

inherit cros-workon autotest

DESCRIPTION="Autotest server tests for Bluetooth"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

# Enable autotest by default.
IUSE="+autotest"

RDEPEND=""
DEPEND="${RDEPEND}
	!<chromeos-base/autotest-server-tests-0.0.2
"

SERVER_IUSE_TESTS="
	+tests_bluetooth_AdapterAudioLink
	+tests_bluetooth_AdapterCLSanity
	+tests_bluetooth_AdapterHIDReports
	+tests_bluetooth_AdapterLEAdvertising
	+tests_bluetooth_AdapterLEHIDSanity
	+tests_bluetooth_AdapterLESanity
	+tests_bluetooth_AdapterMDSanity
	+tests_bluetooth_AdapterPairing
	+tests_bluetooth_AdapterQuickSanity
	+tests_bluetooth_AdapterSASanity
	+tests_bluetooth_AdapterStandalone
	+tests_bluetooth_AdapterSuspendResume
	+tests_bluetooth_Sanity_AdapterPresent
	+tests_bluetooth_Sanity_DefaultState
	+tests_bluetooth_Sanity_Discoverable
	+tests_bluetooth_Sanity_Discovery
	+tests_bluetooth_Sanity_LEDiscovery
	+tests_bluetooth_Sanity_ValidAddress
	+tests_bluetooth_SDP_ServiceAttributeRequest
	+tests_bluetooth_SDP_ServiceBrowse
	+tests_bluetooth_SDP_ServiceSearchAttributeRequest
	+tests_bluetooth_SDP_ServiceSearchRequestBasic
"

IUSE_TESTS="${IUSE_TESTS}
	${SERVER_IUSE_TESTS}
"

IUSE="${IUSE} ${IUSE_TESTS}"

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
