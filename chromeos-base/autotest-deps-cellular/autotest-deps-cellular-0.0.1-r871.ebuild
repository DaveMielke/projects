# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="789f87c87dcacee0584033b21cbf920210b8d336"
CROS_WORKON_TREE="571fdc5432bbbd9a1e7460537485e21014cc357a"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit cros-workon autotest-deponly

DESCRIPTION="Autotest cellular deps"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

# Autotest enabled by default.
IUSE="+autotest"

CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

AUTOTEST_DEPS_LIST="fakegudev fakemodem"
AUTOTEST_CONFIG_LIST=
AUTOTEST_PROFILERS_LIST=

# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"

RDEPEND="!<chromeos-base/autotest-deps-0.0.3"

# deps/fakegudev
RDEPEND="${RDEPEND}
	sys-fs/udev[gudev]
"

# deps/fakemodem
RDEPEND="${RDEPEND}
	chromeos-base/autotest-fakemodem-conf
	dev-libs/dbus-glib
"
DEPEND="${RDEPEND}"

src_configure() {
	cros-workon_src_configure
}
