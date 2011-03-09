# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

inherit cros-workon

DESCRIPTION="Chrome OS verified boot library (firmware build mode)"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~arm"
IUSE="debug"
EAPI="2"

DEPEND="
    sys-boot/chromeos-u-boot-next-build-env
    chromeos-base/vboot_reference"

CROS_WORKON_PROJECT=vboot_reference
CROS_WORKON_LOCALNAME=vboot_reference

src_compile() {
	tc-export CC AR CXX

	# find u-boot-cflags.mk
	local cflags_path="${SYSROOT}/u-boot/u-boot-cflags.mk"
	[ -f "${cflags_path}" ] || die "File ${cflags_path} does not exist"

	local err_msg="${PN} compile failed. "
	err_msg+="Try running 'make clean' in the package root directory"

	local DEBUG=""
	if use debug ; then
		DEBUG=1
	fi

	emake FIRMWARE_ARCH="arm" FIRMWARE_CONFIG_PATH="${cflags_path}" \
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
