# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
CROS_WORKON_COMMIT="7c9315139989844323e9252f8ccaf9e86132ed27"
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
	doexe make_factory_package.sh
	doexe serve_factory_packages.py
	doexe cros_sign_to_ssd
}
