# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

inherit cros-workon toolchain-funcs

DESCRIPTION="Chrome OS verified boot library (firmware build mode)"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="arm x86"
IUSE="debug"
EAPI="2"
CROS_WORKON_COMMIT="c76136cd0de548a2b8a2fc9c8efd2466d0922319"
CROS_WORKON_PROJECT="chromiumos/platform/vboot_reference"

DEPEND="chromeos-base/vboot_reference"

CROS_WORKON_LOCALNAME=vboot_reference

src_compile() {
	tc-export CC AR CXX

	local err_msg="${PN} compile failed. "
	err_msg+="Try running 'make clean' in the package root directory"

	local DEBUG=""
	if use debug ; then
		DEBUG=1
	fi

	# Disable TPM entirely on boards that TPM chip bricks
	local BOARD="${BOARD:-${SYSROOT##/build/}}"
	local MOCK_TPM=""
	if [ ${BOARD} = "tegra2_seaboard" ] ; then
		MOCK_TPM=1
	fi

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
