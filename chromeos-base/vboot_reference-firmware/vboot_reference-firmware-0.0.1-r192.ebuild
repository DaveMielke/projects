# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Chrome OS verified boot library (firmware build mode)"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="arm x86"
IUSE=""
EAPI="2"
CROS_WORKON_COMMIT="64b2ba41cc5b9125c78b6372eb7f9ed51f4b65a6"
CROS_WORKON_PROJECT="chromiumos/platform/vboot_reference"

DEPEND="chromeos-base/vboot_reference"

CROS_WORKON_LOCALNAME=vboot_reference

src_compile() {
	tc-export CC AR CXX

	local err_msg="${PN} compile failed. "
	err_msg+="Try running 'make clean' in the package root directory"

	local DEBUG=""
	if use cros-debug ; then
		DEBUG=1
	fi

	# Disable TPM entirely on boards that TPM chip bricks
	local BOARD="${BOARD:-${SYSROOT##/build/}}"

	# TODO(clchiou) Find a new way to enable MOCK_TPM on all dev boards
	#local MOCK_TPM=""
	#if [ ${BOARD} = "tegra2_seaboard" ] ; then
	#	MOCK_TPM=1
	#fi
	local MOCK_TPM="1"
	case "${BOARD}" in
		tegra2_kaen|tegra2_aebl)
		MOCK_TPM=""
	esac

	emake	FIRMWARE_ARCH="$(tc-arch-kernel)" \
		MOCK_TPM="${MOCK_TPM}" \
		DEBUG="${DEBUG}" || die "${err_msg}"
}

src_install() {
	einfo "Installing header files and libraries"

	# Install firmware/include to /build/${BOARD}/usr/include/vboot
	local dst_dir='/usr/include/vboot'
	dodir "${dst_dir}"
	insinto "${dst_dir}"
	doins -r firmware/include/*

	# Install vboot_fw.a to /build/${BOARD}/usr/lib
	insinto /usr
	dolib.a "${S}"/build/vboot_fw.a
}
