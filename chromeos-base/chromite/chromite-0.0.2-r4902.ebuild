# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="8679d594ec31c11d77ffa1dba03fb2adbc033697"
CROS_WORKON_TREE="4afc5a63b43298465d05acae9a14550acb4f71c9"
CROS_WORKON_PROJECT="chromiumos/chromite"
CROS_WORKON_LOCALNAME="../../chromite"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-constants cros-workon python

DESCRIPTION="Wrapper for running chromite unit tests"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/chromite/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host"

src_install() {
	use cros_host && return
	insinto "$(python_get_sitedir)/chromite"
	doins -r "${S}"/*
	# TODO (crbug.com/346859) Convert to using distutils and a setup.py
	# to specify which files should be installed.
	cd "${D}/$(python_get_sitedir)/chromite"
	find '(' -name '*.py[co]' -o -name '*unittest.py' ')' -delete
	find -name '.git' -exec rm -rf {} +
	rm -rf \
		appengine \
		cidb \
		lib/datafiles/ \
		third_party/pyelftools/test \
		mobmonitor \
		venv
}

src_test() {
	# Run the chromite unit tests, resetting the environment to the standard
	# one using a sudo invocation. Currently the tests assume they run from a
	# repo checkout, so they need to be run from the real source dir.
	# TODO(davidjames): Fix that, and run the tests from ${S} instead.
	cd "${CHROMITE_DIR}" && sudo -u "${PORTAGE_USERNAME}" \
		PATH="${CROS_WORKON_SRCROOT}/../depot_tools:${PATH}" ./run_tests || die
}
