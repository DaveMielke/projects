# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="8313563097d5e3fdcb20a71974dff1ae7b7b78f5"
CROS_WORKON_TREE="4e3350fd72a53fe4bc2b29ff06d16d32c8eac46c"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest

DESCRIPTION="p2p autotests"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
# Enable autotest by default.
IUSE="+autotest"

RDEPEND="
	!<chromeos-base/autotest-tests-0.0.3
	chromeos-base/autotest-deps-p2p
"
DEPEND="${RDEPEND}"

IUSE_TESTS="
	+tests_p2p_ConsumeFiles
	+tests_p2p_ServeFiles
	+tests_p2p_ShareFiles
"

IUSE="${IUSE} ${IUSE_TESTS}"

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
