# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# WARNING: cros_workon cannot detect changes to files/, please ensure
# that you manually bump or make some change to the 9999 ebuild until
# this is fixed.

EAPI=2
CROS_WORKON_COMMIT="84cf482da2c249c2118b519f1cb9e56935a6c384"
CROS_WORKON_PROJECT="chromiumos/platform/initramfs"

inherit cros-workon

DESCRIPTION="Create Chrome OS initramfs"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE=""
DEPEND="chromeos-base/chromeos-installer
	chromeos-base/vboot_reference
	media-gfx/ply-image
	sys-apps/busybox
	sys-fs/lvm2"
RDEPEND=""

CROS_WORKON_LOCALNAME="../platform/initramfs"

INITRAMFS_TMP_S=${WORKDIR}/initramfs_tmp
# Suffixed with cpio or not recognize filetype.
INITRAMFS_FILE="initramfs.cpio.gz"

build_initramfs_file() {
	mkdir -p ${INITRAMFS_TMP_S}/bin ${INITRAMFS_TMP_S}/sbin
	mkdir -p ${INITRAMFS_TMP_S}/usr/bin ${INITRAMFS_TMP_S}/usr/sbin
	mkdir -p ${INITRAMFS_TMP_S}/etc ${INITRAMFS_TMP_S}/dev
	mkdir -p ${INITRAMFS_TMP_S}/root ${INITRAMFS_TMP_S}/proc
	mkdir -p ${INITRAMFS_TMP_S}/sys ${INITRAMFS_TMP_S}/usb
	mkdir -p ${INITRAMFS_TMP_S}/newroot
	mkdir -p ${INITRAMFS_TMP_S}/lib ${INITRAMFS_TMP_S}/usr/lib
	mkdir -p ${INITRAMFS_TMP_S}/stateful ${INITRAMFS_TMP_S}/tmp
	mkdir -p ${INITRAMFS_TMP_S}/log

	# Copy source files not merged from our dependencies.
	cp "${S}/init" "${INITRAMFS_TMP_S}/init" || die
	chmod +x "${INITRAMFS_TMP_S}/init"
	for shlib in *.sh; do
		cp "${S}"/${shlib} ${INITRAMFS_TMP_S}/lib || die
	done
	cp -r ${S}/screens ${INITRAMFS_TMP_S}/etc || die

	# Load libraries for busybox and dmsetup
	# TODO: how can ebuilds support static busybox?
	if use x86 ; then
		LIBS="
			ld-linux.so.2
			../usr/lib/libdrm_intel.so.1.0.0
		"
	else
		# TODO ARM: why does arm use a different dynamic linker here?
		LIBS="
			ld-linux.so.3
		"
	fi

	LIBS="${LIBS}
		libm.so.6
		libc.so.6
		../usr/lib/libcrypto.so.0.9.8
		../usr/lib/libpng12.so.0.44.0
		../usr/lib/libdrm.so.2.4.0
		libdevmapper.so.1.02
		libdl.so.2
		libpam.so.0
		libpam_misc.so.0
		libpthread.so.0
		librt.so.1
		libz.so.1
	"
	for lib in $LIBS; do
		cp ${ROOT}/lib/${lib} ${INITRAMFS_TMP_S}/lib || die
	done
	ln -s libpng12.so.0.44.0 ${INITRAMFS_TMP_S}/lib/libpng12.so.0
	ln -s libpng12.so.0.44.0 ${INITRAMFS_TMP_S}/lib/libpng12.so
	ln -s libdrm.so.2.4.0 ${INITRAMFS_TMP_S}/lib/libdrm.so
	ln -s libdrm.so.2.4.0 ${INITRAMFS_TMP_S}/lib/libdrm.so.2
	if use x86 ; then
		ln -s libdrm_intel.so.1.0.0 ${INITRAMFS_TMP_S}/lib/libdrm_intel.so
		ln -s libdrm_intel.so.1.0.0 ${INITRAMFS_TMP_S}/lib/libdrm_intel.so.1
	fi

	cp ${ROOT}/bin/busybox ${INITRAMFS_TMP_S}/bin || die
	ln -s "busybox" "${INITRAMFS_TMP_S}/bin/sh"

	# For verified rootfs
	cp ${ROOT}/sbin/dmsetup ${INITRAMFS_TMP_S}/bin || die

	# For message screen display
	cp ${ROOT}/usr/bin/ply-image ${INITRAMFS_TMP_S}/bin || die

	# For recovery behavior
	cp ${ROOT}/usr/bin/tpmc ${INITRAMFS_TMP_S}/bin || die
	cp ${ROOT}/usr/bin/dev_sign_file ${INITRAMFS_TMP_S}/bin || die
	cp ${ROOT}/usr/bin/vbutil_kernel ${INITRAMFS_TMP_S}/bin || die
	cp ${ROOT}/usr/bin/crossystem ${INITRAMFS_TMP_S}/bin || die

	# Insure cgpt is statically linked
	file ${ROOT}/usr/bin/cgpt | grep -q "statically linked" || die
	cp ${ROOT}/usr/bin/cgpt ${INITRAMFS_TMP_S}/usr/bin || die

	cp ${ROOT}/usr/sbin/chromeos-common.sh ${INITRAMFS_TMP_S}/usr/sbin || die
	cp ${ROOT}/usr/sbin/chromeos-findrootfs ${INITRAMFS_TMP_S}/usr/sbin || die

	# The kernel emake expects the file in cpio format.
	( cd "${INITRAMFS_TMP_S}"
	  find . | cpio -o -H newc |
		gzip -9 > "${WORKDIR}/${INITRAMFS_FILE}" ) ||
		die "cannot package initramfs"
}

src_compile() {
	einfo "Creating ${INITRAMFS_FILE}"
	build_initramfs_file
	INITRAMFS_FILE_SIZE=$(stat --printf="%s" "${WORKDIR}/${INITRAMFS_FILE}")
	einfo "${INITRAMFS_FILE}: ${INITRAMFS_FILE_SIZE} bytes"
}

src_install() {
	dodir /boot
	dobin ${WORKDIR}/${INITRAMFS_FILE}
}
