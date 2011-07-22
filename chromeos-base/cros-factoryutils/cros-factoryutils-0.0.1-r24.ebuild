# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
CROS_WORKON_COMMIT="fba7693f0069605d223f2673e6f09b548c49ad39"
CROS_WORKON_PROJECT="chromiumos/platform/factory-utils"

inherit cros-workon

DESCRIPTION="Development utilities for ChromiumOS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

CROS_WORKON_LOCALNAME="factory-utils"

# dev-utils contains the devserver
RDEPEND="app-shells/bash
	dev-util/crosutils
	chromeos-base/cros-devutils[cros_host]
	"

DEPEND="${RDEPEND}"

src_install() {
	exeinto /usr/bin

	doexe mk_memento_images_factory.sh
	doexe serve_factory_packages.py
	doexe update_firmware_vars.py
}
