# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="1c0b8dc816980061dfd048d62eff8a7f4bc594c6"
CROS_WORKON_TREE="5daaa7f4e159bfc43d065b8288df8d9a0051db21"
CROS_WORKON_PROJECT="chromiumos/platform/ec"
CROS_WORKON_LOCALNAME="ec"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1

inherit cros-workon

DESCRIPTION="Chrome OS EC Utility Helper"

HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="chromeos-base/ec-utils"

src_compile() {
	:
}

src_install() {
	dosbin "util/inject-keys.py"
}
