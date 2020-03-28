# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="08733aa7d62b171c667d3eb7e299aa7345053fa9"
CROS_WORKON_TREE="a2ebeab302f15e405e7e8c355ad74871e767e812"
CROS_WORKON_PROJECT="chromiumos/third_party/ltp"
CROS_WORKON_LOCALNAME=../third_party/ltp

inherit cros-workon cros-constants

DESCRIPTION="Autotest kernel ltp dep"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
KEYWORDS="*"

# Autotest enabled by default.
IUSE="+autotest"

AUTOTEST_DEPS_LIST=""

# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"

src_prepare() {
	# Reset timetstamps since they might get out of sync with git.
	find utils/ffsb-6.0-rc2 -exec touch -r . {} + || die
	# Now rebuild autotools for dirs not checked in.
	emake autotools
}

src_configure() {
	econf --prefix="${AUTOTEST_BASE}/client/deps/kernel_ltp_dep"
	# Used in make install
	export SKIP_IDCHECK=1
}
