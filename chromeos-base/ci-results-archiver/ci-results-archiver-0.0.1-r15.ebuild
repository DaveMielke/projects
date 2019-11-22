# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="93ab9b239bda42be2f433acbcd5ba0ed72398a72"
CROS_WORKON_TREE="3c3451ad946884a773068352f8bcd3f3af556134"
CROS_WORKON_PROJECT="chromiumos/infra/ci_results_archiver"
CROS_WORKON_LOCALNAME="../../infra/ci_results_archiver"

CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="Pipeline to archive continuous integration results."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/infra/ci_results_archiver/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND=""
DEPEND=""

# No file is installed by this package; the whole purpose of this package is to
# run unit tests.

src_test() {
	# Pass some options to avoid writing to the write-protected directory.
	# TODO(crbug.com/808434): Reenable unit tests once we understand the
	# root cause
	# bin/run_tests -p no:cacheprovider --no-cov || die "Unit tests failed"
	:
}
