# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# This ebuild is for running tast DLC test in the lab and local dev setup.
# For future DLC autotests, a new installation process needs to be re-designed.

EAPI=6

CROS_WORKON_COMMIT="aee900687fa79e30af9227db2469b4be3b4cd7b8"
CROS_WORKON_TREE=("cf70f5427742ea78d990d9a36dc8ef17f930348a" "a7054021f1976533096a10b32b8b2e4217a1d66b" "798e01ef051b54ee67a88a5fc7818ecadc893275")
PYTHON_COMPAT=( python2_7 python3_{6,7} )

CROS_WORKON_PROJECT="chromiumos/platform/dev-util"
CROS_WORKON_LOCALNAME="platform/dev"
CROS_WORKON_OUTOFTREE_BUILD="1"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_SUBTREE="nebraska stateful_update quick-provision"

inherit cros-workon python-r1

DESCRIPTION="A set of utilities for updating Chrome OS."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/dev-util/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="!chromeos-base/gmerge"

# Add an empty src_compile() so we bypass compile stage.
src_compile() { :; }

src_install() {
	into /usr/local
	dobin nebraska/nebraska.py
	dobin stateful_update
	dobin quick-provision/quick-provision

	# Install the nebraska as a library too to be used by autotests.
	install_nebraska() {
		# TODO(crbug.com/771085): Clear the SYSROOT var as python will
		# use that to define the sitedir which means we end up
		# installing into a path like /build/$BOARD/build/$BOARD/xxx.
		# This is a bug in the core python logic, but this is breaking
		# moblab, so hack it for now.
		insinto "$(python_get_sitedir | sed "s:^${SYSROOT}::")/nebraska"
		doins "nebraska/nebraska.py"
	}
	python_foreach_impl install_nebraska
}

src_test() {
	# Run the unit tests.
	python_test() {
		"$PYTHON" nebraska/nebraska_unittest.py || die
	}
	python_foreach_impl python_test
}
