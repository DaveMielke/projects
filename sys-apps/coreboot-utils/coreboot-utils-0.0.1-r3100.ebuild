# Copyright 2012 The Chromium OS Authors
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="4"
CROS_WORKON_COMMIT=("4b86cf9b8c33aae8b455383ca45e977727cb7418" "e95ceff307f6c5c457f3e805991804ae2c7cb50c")
CROS_WORKON_TREE=("30f4bc0a0251f6f452d2813cf8126a0ae66c7adb" "c9ac67df0a7ff60002851d9447da24fcc212b41a")
CROS_WORKON_PROJECT=(
	"chromiumos/third_party/coreboot"
	"chromiumos/platform/vboot_reference"
)
CROS_WORKON_LOCALNAME=(
	"coreboot"
	"../platform/vboot_reference"
)
CROS_WORKON_DESTDIR=(
	"${S}"
	"${S}/3rdparty/vboot"
)

inherit cros-workon toolchain-funcs

DESCRIPTION="Utilities for modifying coreboot firmware images"
HOMEPAGE="http://coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host mma +pci"

RDEPEND="pci? ( sys-apps/pciutils )"
DEPEND="${RDEPEND}"

src_configure() {
	cros-workon_src_configure
}

is_x86() {
	use x86 || use amd64
}

src_compile() {
	tc-export CC
	emake -C util/cbfstool obj="${PWD}/util/cbfstool"
	if use cros_host; then
		emake -C util/archive CC="${CC}"
	else
		emake -C util/cbmem CC="${CC}"
	fi
	if is_x86; then
		if use cros_host; then
			emake -C util/ifdtool
		else
			emake -C util/superiotool CC="${CC}" \
				CONFIG_PCI=$(usex pci)
			emake -C util/inteltool CC="${CC}"
			emake -C util/nvramtool CC="${CC}"
		fi
	fi
}

src_install() {
	dobin util/cbfstool/cbfstool
	if use cros_host; then
		dobin util/cbfstool/fmaptool
		dobin util/cbfstool/cbfs-compression-tool
		dobin util/archive/archive
	else
		dobin util/cbmem/cbmem
	fi
	if is_x86; then
		if use cros_host; then
			dobin util/ifdtool/ifdtool
		else
			dobin util/superiotool/superiotool
			dobin util/inteltool/inteltool
			dobin util/nvramtool/nvramtool
		fi
		if use mma; then
			dobin util/mma/mma_setup_test.sh
			dobin util/mma/mma_get_result.sh
			dobin util/mma/mma_automated_test.sh
			insinto /etc/init
			doins util/mma/mma.conf
		fi
	fi
}
