# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="8e3343fc855273fcc2109a463b82e321bf0ab556"
CROS_WORKON_TREE="ef6031394a4d403dead12c5a7a5572a59b6a8396"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit cros-workon autotest-deponly

DESCRIPTION="Autotest audioloop dep"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"

# Autotest enabled by default.
IUSE="+autotest"

CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

AUTOTEST_DEPS_LIST="audioloop"

# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"

# deps/audioloop
RDEPEND="${RDEPEND}
	media-libs/alsa-lib"

DEPEND="${RDEPEND}"

