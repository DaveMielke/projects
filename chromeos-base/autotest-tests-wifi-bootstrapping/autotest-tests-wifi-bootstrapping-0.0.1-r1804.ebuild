# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="21922c807733cab1a86096500304aa8ae68bd897"
CROS_WORKON_TREE="5ac46cdb37bbda5ff5da849bcd34602d35ebf3d5"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest

DESCRIPTION="autotests for the WiFi bootstrapping process"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
# Enable autotest by default.
IUSE="+autotest peerd wifi_bootstrapping"
# We depend on peerd to provide some services, so enable those
# tests as well.
REQUIRED_USE="wifi_bootstrapping? ( peerd )"

IUSE_TESTS="
	+tests_apmanager_CheckAPProcesses
	+tests_buffet_PrivetInfo
	+tests_buffet_PrivetSetupFlow
	+tests_buffet_WebServerSanity
	+tests_platform_CheckWiFiBootstrappingProcesses
"

IUSE="${IUSE} ${IUSE_TESTS}"

# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"
