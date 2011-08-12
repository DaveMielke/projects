# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="2131222c6d31caf345c3f879d09b37316f96062f"
CROS_WORKON_PROJECT="chromiumos/platform/factory_test_init"

inherit cros-workon

DESCRIPTION="Upstart jobs for the Chrome OS factory test image"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

DEPEND=""

RDEPEND="chromeos-base/chromeos-init
	sys-apps/coreutils
	sys-apps/module-init-tools
	sys-apps/upstart
	sys-process/procps
	"

CROS_WORKON_LOCALNAME="factory_test_init"

src_install() {
	dodir /etc/init
	insinto /etc/init
	doins factory.conf
	doins factorylog.conf
}
