# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="0697ccd2453b9eafc087e1e6a7bdb289b81b45ed"
CROS_WORKON_TREE="bb9480065dc6201235cef902c97cb553efa12786"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit toolchain-funcs flag-o-matic cros-workon autotest

DESCRIPTION="ltp autotest"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
# Enable autotest by default.
IUSE="+autotest"

RDEPEND="${RDEPEND}
	chromeos-base/autotest-deps-ltp
	chromeos-base/protofiles
	dev-libs/protobuf-python
	dev-python/pygobject
	!<chromeos-base/autotest-tests-0.0.1-r1723
"

DEPEND="${RDEPEND}"

IUSE_TESTS="
	+tests_kernel_LTP
"

IUSE="${IUSE} ${IUSE_TESTS}"

CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

AUTOTEST_DEPS_LIST=""
AUTOTEST_CONFIG_LIST=""
AUTOTEST_PROFILERS_LIST=""

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"

src_configure() {
	cros-workon_src_configure
}
