# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit python

DESCRIPTION="Chromium telemetry dep"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"

# Ensure the telemetry dep tarball is created already.
DEPEND="chromeos-base/chromeos-chrome"
RDEPEND=""

S=${WORKDIR}

src_unpack() {
	ln -s "${SYSROOT}/usr/local/autotest/packages/dep-telemetry_dep.tar.bz2" .
	unpack ./dep-telemetry_dep.tar.bz2
	# Some telemetry code hardcodes in 'src'
	mv test_src src || die
}

src_install() {
	insinto /usr/local/telemetry
	doins -r "${WORKDIR}"/*

	# Add telemetry to the python path.
	dodir "$(python_get_sitedir)"
	echo "/usr/local/telemetry/src/tools/telemetry" > \
		"${ED}$(python_get_sitedir)/telemetry.pth" || die
}
