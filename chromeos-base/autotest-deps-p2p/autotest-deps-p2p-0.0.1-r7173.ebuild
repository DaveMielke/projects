# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="1f18f88cc6a294f5fe19f69f9ba522312f7f8f65"
CROS_WORKON_TREE="e39e96427f3ed12f9d7e96bc998de8d49791cd44"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME="third_party/autotest/files"

PYTHON_COMPAT=( python2_7 )
inherit cros-workon autotest-deponly python-any-r1

DESCRIPTION="Autotest p2p deps"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/autotest/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

# Autotest enabled by default.
IUSE="+autotest"

AUTOTEST_DEPS_LIST="lansim"

# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"

RDEPEND="!<chromeos-base/autotest-deps-0.0.4"

# deps/lansim
RDEPEND="${RDEPEND}
	dev-python/dpkt
"
DEPEND="${RDEPEND}"
