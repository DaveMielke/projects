# Copyright 2011 The Chromium OS Authors
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="4"
CROS_WORKON_COMMIT="193121d636c6e776b221201628c9a30a45e6a673"
CROS_WORKON_TREE="0ea291034f5606d13681ad0bdbcd521b25763137"
CROS_WORKON_PROJECT="chromiumos/third_party/flashmap"

inherit cros-workon toolchain-funcs multilib python

DESCRIPTION="Utility for manipulating firmware ROM mapping data structure"
HOMEPAGE="http://flashmap.googlecode.com"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

# Disable unit testing for now because one of the test cases for detecting
# buffer overflow causes emake to fail when fmap_test is run.
# RESTRICT="test" will override FEATURES="test" and will also cause
# src_test() to be ignored by relevant scripts.
RESTRICT="test"
FEATURES="test"

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	tc-export AR CC LD NM STRIP OBJCOPY
	emake || die
}

src_test() {
	tc-export AR CC LD NM STRIP OBJCOPY
	# default "test" target uses lcov, so "test_only" was added to only
	# build and run the test without generating coverage statistics
	emake test_only || die
}

src_install() {
	emake LIBDIR=$(get_libdir) DESTDIR="${D}" USE_PKG_CONFIG=1 install || die

	insinto "$(python_get_sitedir)"
	# Copy the python files in this directory except __init__.py
	doins "fmap.py"
}
