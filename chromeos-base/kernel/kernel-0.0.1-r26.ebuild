# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="4ef19b8f1d53ab28ba9dc76de832b1f874a32dcf"
inherit toolchain-funcs

DESCRIPTION="Chrome OS Kernel"
HOMEPAGE="http://src.chromium.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE="-compat_wireless"

DEPEND="sys-apps/debianutils"
RDEPEND="chromeos-base/kernel-headers" # Temporary hack

vmlinux_text_base=${CHROMEOS_U_BOOT_VMLINUX_TEXT_BASE:-0x20008000}

# Use a single or split kernel config as specified in the board or variant
# make.conf overlay. Default to the arch specific split config if an
# overlay or variant does not set either CHROMEOS_KERNEL_CONFIG or
# CHROMEOS_KERNEL_SPLITCONFIG. CHROMEOS_KERNEL_CONFIG is set relative
# to the root of the kernel source tree.

if [ -n "${CHROMEOS_KERNEL_CONFIG}" ]; then
	config="${S}/${CHROMEOS_KERNEL_CONFIG}"
else
	if [ "${ARCH}" = "x86" ]; then
		config=${CHROMEOS_KERNEL_SPLITCONFIG:-"chromeos-intel-menlow"}
	elif [ "${ARCH}" = "arm" ]; then
		config=${CHROMEOS_KERNEL_SPLITCONFIG:-"qsd8650-st1"}
	fi
fi

if [ "${CHROMEOS_KERNEL}" = "kernel-nvidia" ]; then
	CROS_WORKON_LOCALNAME="../third_party/kernel-nvidia"
	EGIT_BRANCH="nvidia-2.6.31.12"
elif [ "${CHROMEOS_KERNEL}" = "kernel-qualcomm" ]; then
	CROS_WORKON_LOCALNAME="../third_party/kernel-qualcomm"
	EGIT_BRANCH=qualcomm-2.6.32.9
else
	# TODO(jglasgow) Need to fix DEPS file to get rid of "files"
	CROS_WORKON_LOCALNAME="../third_party/kernel/files"
fi

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon

# Allow override of kernel arch.
kernel_arch=${CHROMEOS_KERNEL_ARCH:-"$(tc-arch-kernel)"}

cross=${CHOST}-
# Hack for using 64-bit kernel with 32-bit user-space
if [ "${ARCH}" = "x86" -a "${kernel_arch}" = "x86_64" ]; then
    cross=${CBUILD}-
fi

src_configure() {
	elog "Using kernel config: ${config}"

	if [ -n "${CHROMEOS_KERNEL_CONFIG}" ]; then
		cp -f "${config}" "${S}"/.config || die
	else
		chromeos/scripts/prepareconfig ${config} || die
	fi

	# Use default for any options not explitly set in splitconfig
	yes "" | emake ARCH=${kernel_arch} oldconfig || die

	if use compat_wireless; then
		"${S}"/chromeos/scripts/compat_wireless_config "${S}"
	fi
}

src_compile() {
	emake \
		ARCH=${kernel_arch} \
		CROSS_COMPILE="${cross}" || die

	if use compat_wireless; then
		# compat-wireless support must be done after
		emake M=chromeos/compat-wireless \
			ARCH=${kernel_arch} \
			CROSS_COMPILE="${cross}" || die
	fi
}

headers_install() {
	emake \
	  ARCH=${kernel_arch} \
	  CROSS_COMPILE="${cross}" \
	  INSTALL_HDR_PATH="${D}"/usr \
	  headers_install || die

	#
	# These subdirectories are installed by various ebuilds and we don't
	# want to conflict with them.
	#
	rm -rf "${D}"/usr/include/sound
	rm -rf "${D}"/usr/include/scsi
	rm -rf "${D}"/usr/include/drm

	#
	# Double hack, install the Qualcomm drm header anyway, its not included in
	# libdrm, and is required to build xf86-video-msm.
	#
	if [ -r "${S}"/include/drm/kgsl_drm.h ]; then
		insinto /usr/include/drm
		doins "${S}"/include/drm/kgsl_drm.h
	fi
}

src_install() {
	dodir boot

	emake \
		ARCH=${kernel_arch}\
		CROSS_COMPILE="${cross}" \
		INSTALL_PATH="${D}/boot" \
		install || die

	emake \
		ARCH=${kernel_arch}\
		CROSS_COMPILE="${cross}" \
		INSTALL_MOD_PATH="${D}" \
		modules_install || die

	if use compat_wireless; then
		# compat-wireless modules are built+installed separately
		# NB: the updates dir is handled specially by depmod
		emake M=chromeos/compat-wireless \
			ARCH=${kernel_arch}\
			CROSS_COMPILE="${cross}" \
			INSTALL_MOD_DIR=updates \
			INSTALL_MOD_PATH="${D}" \
			modules_install || die
	fi

	emake \
		ARCH=${kernel_arch}\
		CROSS_COMPILE="${cross}" \
		INSTALL_MOD_PATH="${D}" \
		firmware_install || die

	headers_install

	if [ "${ARCH}" = "arm" ]; then
		version=$(ls "${D}"/lib/modules)

		cp -a \
			"${S}"/arch/"${ARCH}"/boot/zImage \
			"${D}/boot/vmlinuz-${version}" || die

		cp -a \
			"${S}"/System.map \
			"${D}/boot/System.map-${version}" || die

		cp -a \
			"${S}"/.config \
			"${D}/boot/config-${version}" || die

		ln -sf "vmlinuz-${version}"    "${D}"/boot/vmlinuz    || die
		ln -sf "System.map-${version}" "${D}"/boot/System.map || die
		ln -sf "config-${version}"     "${D}"/boot/config     || die

		dodir /boot

		/usr/bin/mkimage -A "${ARCH}" \
							-O linux \
							-T kernel \
							-C none \
							-a ${vmlinux_text_base} \
							-e ${vmlinux_text_base} \
							-n kernel \
							-d "${D}"/boot/vmlinuz \
							"${D}"/boot/vmlinux.uimg || die
	fi
}
