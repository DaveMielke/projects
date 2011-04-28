# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit cros-workon

DESCRIPTION="ChromeOS firmware utilities installer"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

# This target list should be architecture specific
# (no ACPI stuff on ARM fot instance)
TARGETS='gpio_setup reboot_mode'

src_compile() {
    tc-export CXX PKG_CONFIG
    emake ${TARGETS} || die "compilation failed."
}

src_install() {
    dosbin ${TARGETS} || die "installation failed ($?)"
}
