# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="Ebuild which pulls in any necessary ebuilds as dependencies
or portage actions."

SLOT="0"
KEYWORDS="-* amd64 x86"
S="${WORKDIR}"
IUSE="skl_lpe"
# Add dependencies on other ebuilds from within this board overlay
RDEPEND="
	media-libs/lpe-support-topology
	media-libs/lpe-support-blacklist
	skl_lpe? ( sys-kernel/linux-firmware[linux_firmware_adsp_skl] )
"
DEPEND="${RDEPEND}"
