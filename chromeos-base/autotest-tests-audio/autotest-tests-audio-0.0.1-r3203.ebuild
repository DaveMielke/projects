# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="92c5c0f4d40693339289ce3874965b3cead76492"
CROS_WORKON_TREE="d51479d309d436d20785128e6d602e9d558012bd"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME="third_party/autotest/files"

inherit cros-workon autotest

DESCRIPTION="Audio autotests"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/autotest/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
# Enable autotest by default.
IUSE="+autotest"

RDEPEND="
	!<chromeos-base/autotest-tests-0.0.3
	chromeos-base/audiotest
"
DEPEND="${RDEPEND}"

IUSE_TESTS="
	+tests_audio_Aconnect
	+tests_audio_AlsaLoopback
	+tests_audio_Aplay
	+tests_audio_CRASFormatConversion
	+tests_audio_CrasDevSwitchStress
	+tests_audio_CrasLoopback
	+tests_audio_CrasPinnedStream
	+tests_audio_CrasStress
	+tests_audio_LoopbackLatency
"

IUSE="${IUSE} ${IUSE_TESTS}"

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"