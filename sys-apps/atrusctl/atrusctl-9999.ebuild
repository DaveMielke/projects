# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_PROJECT="chromiumos/third_party/atrusctl"

inherit cros-workon cmake-utils

DESCRIPTION="A tool to interact with an Atrus device from Chromium OS."
HOMEPAGE="http://www.limesaudio.com/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~*"

DEPEND="virtual/libusb:1"
RDEPEND="${DEPEND}"

src_install() {
	dosbin "${BUILD_DIR}/src/atrusctl"
}
