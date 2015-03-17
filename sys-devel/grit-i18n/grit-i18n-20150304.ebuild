# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
PYTHON_COMPAT=( python2_7 )

inherit python-single-r1

# To roll grit to a new version:
#  1. Determine the commit to roll to and update GIT_SHA1 below.
#  2. Obtain a tarball corresponding to ${GIT_SHA1} from
#     https://chromium.googlesource.com/external/grit-i18n/+archive/${GIT_SHA1}.tar.gz
#  3. Upload the tarball as ${PN}-${GIT_SHA1}.tar.gz to
#     chromeos-localmirror/distfiles
#  4. Rename the ebuild, using the date corresponding to ${GIT_SHA1}'s commit
#     time stamp as the new version.
GIT_SHA1="5b56593a81a883b49509e2e51a779aefd8df3148"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${PN}-${GIT_SHA1}.tar.gz"

DESCRIPTION="GRIT - Google Resource and Internationalization Tool"
HOMEPAGE="https://code.google.com/p/grit-i18n/"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="*"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="${PYTHON_DEPS}"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_install() {
	python_domodule grit
	python_newscript grit.py grit

	# Delete unneeded stuff pulled in from the source tree.
	local grit_module_dir="${ED}/$(python_get_sitedir)/grit"
	rm -rf "${grit_module_dir}"/{testdata,grit-todo.xml}
	find "${grit_module_dir}" \
		-regex '.*/\(.*_unittest.*\|PRESUBMIT\)\.py[co]?$' \
		-delete
}
