# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="679f85df8c8c572a11cf14da9828610386c3849d"
CROS_WORKON_PROJECT="chromiumos/platform/saft"

inherit cros-workon

DESCRIPTION="ChromeOS SAFT installer"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="x86"
IUSE=""

DEPEND="x86? ( chromeos-base/vboot_reference
               >=chromeos-base/chromeos-firmware-0.0.1-r27 )"

src_install() {
    dstdir="/usr/sbin/firmware/saft"
    dodir "${dstdir}"
    exeinto "${dstdir}"
    doexe *.{py,sh}
}
