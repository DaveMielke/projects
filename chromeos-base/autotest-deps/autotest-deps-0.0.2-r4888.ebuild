# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="586d7b85d9b7e52f756469c28743bb574d8a0330"
CROS_WORKON_TREE="8405413646253a2cc68506e6766ba1a92dbba01a"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit cros-workon autotest-deponly

DESCRIPTION="Autotest common deps"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm amd64"

# Autotest enabled by default.
IUSE="+autotest"

CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

# following deps don't compile: boottool, mysql, pgpool, pgsql, systemtap, # dejagnu, libcap, libnet
# following deps are not deps: factory
# following tests are going to be moved: chrome_test
AUTOTEST_DEPS_LIST="fio gfxtest gtest iwcap lansim realtimecomm_playground sysstat fakegudev fakemodem pyxinput example_cros_dep"
AUTOTEST_CONFIG_LIST=*
AUTOTEST_PROFILERS_LIST=*

# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"

# deps/gtest
RDEPEND="
  dev-cpp/gtest
"

RDEPEND="${RDEPEND}
  chromeos-base/autotest-deps-libaio
"

# deps/lansim
RDEPEND="${RDEPEND}
  dev-python/dpkt
"

# deps/iwcap
RDEPEND="${RDEPEND}
  dev-libs/libnl:0
"

# deps/fakegudev
RDEPEND="${RDEPEND}
  sys-fs/udev[gudev]
"

# deps/fakemodem
RDEPEND="${RDEPEND}
  chromeos-base/autotest-fakemodem-conf
"

RDEPEND="${RDEPEND}
  sys-devel/binutils
"
DEPEND="${RDEPEND}"

src_configure() {
	cros-workon_src_configure
}

src_prepare() {
	autotest-deponly_src_prepare

	# To avoid a file collision with autotest.ebuild, remove
	# one particular __init__.py file from working directory.
	# See crbug.com/324963 for context.
	rm "${AUTOTEST_WORKDIR}/client/profilers/__init__.py"
}
