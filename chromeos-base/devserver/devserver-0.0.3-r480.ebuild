# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="80dfa8e69f8c7a4380b2f9feee0e9f05d9f8c9bb"
CROS_WORKON_TREE="e90363d93750cea644e8c8db4889505cc56a8d80"
CROS_WORKON_PROJECT="chromiumos/platform/dev-util"
CROS_WORKON_LOCALNAME="dev"
CROS_WORKON_OUTOFTREE_BUILD="1"

inherit cros-workon

DESCRIPTION="Server to cache Chromium OS build artifacts from Google Storage."
HOMEPAGE="http://dev.chromium.org/chromium-os/how-tos-and-troubleshooting/using-the-dev-server"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="!<chromeos-base/cros-devutils-0.0.4
	chromeos-base/devserver-deps
"
DEPEND="
	dev-python/psutil
"

src_install() {
	emake install DESTDIR="${D}"

	dobin host/start_devserver

	dosym /build /var/lib/devserver/static/pkgroot
	dosym /var/lib/devserver/static /usr/lib/devserver/static

	# Install Mob* Monitor checkfiles for the devserver.
	insinto "/etc/mobmonitor/checkfiles/devserver/"
	doins -r "${S}/checkfiles/devserver/"*
}

src_test() {
	# Run the unit tests.
	./run_unittests || die
}
