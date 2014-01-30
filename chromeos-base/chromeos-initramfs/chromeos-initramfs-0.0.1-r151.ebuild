# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="eac79c9bf89e003546d2376342b25d068c7e9b08"
CROS_WORKON_TREE="8f49d162c924c1cafcedf1c3b3c6a2e6607838ad"
CROS_WORKON_PROJECT="chromiumos/platform/initramfs"
CROS_WORKON_LOCALNAME="initramfs"
CROS_WORKON_OUTOFTREE_BUILD="1"

inherit cros-workon cros-board

DESCRIPTION="Create Chrome OS initramfs"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="netboot_ramfs"

# Dependencies used to build the netboot initramfs.
# Look for the `idobin` and such calls.
DEPEND_netboot="
	app-arch/sharutils
	app-shells/bash
	chromeos-base/chromeos-factoryinstall
	chromeos-base/chromeos-init
	chromeos-base/chromeos-installer
	chromeos-base/chromeos-installshim
	chromeos-base/memento_softwareupdate
	dev-libs/openssl
	dev-util/shflags
	net-misc/wget
	sys-apps/coreutils
	sys-apps/iproute2
	sys-apps/util-linux
	sys-block/parted
	sys-fs/dosfstools
	sys-fs/e2fsprogs
"
DEPEND="chromeos-base/chromeos-assets
	chromeos-base/chromeos-assets-split
	chromeos-base/vboot_reference
	chromeos-base/vpd
	media-gfx/ply-image
	sys-apps/busybox[-make-symlinks]
	sys-apps/flashrom
	sys-apps/pv
	sys-fs/lvm2
	netboot_ramfs? ( ${DEPEND_netboot} )"
RDEPEND=""

src_prepare() {
	local srcroot='/mnt/host/source'
	BUILD_LIBRARY_DIR="${srcroot}/src/scripts/build_library"

	# Need the lddtree from the chromite dir.
	local chromite_bin="${srcroot}/chromite/bin"
	export PATH="${chromite_bin}:${PATH}"
}

# doexe for initramfs
idoexe() {
	einfo "Copied: $*"
	lddtree \
		--verbose \
		--copy-non-elfs \
		--root="${SYSROOT}" \
		--copy-to-tree="${INITRAMFS_TMP_S}" \
		--libdir='/lib' \
		"$@" || die "failed to copy $*"
}

# dobin for initramfs
idobin() {
	idoexe --bindir='/bin' "$@"
}

# Special handling for futility wrapper. This will go away once futility is
# converted to a single binary.
idofutility() {
	local src base
	idobin "$@"
	for src in "$@"; do
		base=$(basename "${src}")
		mv -f "${INITRAMFS_TMP_S}/bin/${base}" \
			"${INITRAMFS_TMP_S}/bin/old_bins/${base}" ||
			die "Cannot mv: ${src}"
		ln -sf futility "${INITRAMFS_TMP_S}/bin/${base}" ||
			die "Cannot symlink: ${src}"
		einfo "Symlinked: /bin/${base} -> futility"
	done
}

# install a list of images (presumably .png files) in /etc/screens
insimage() {
	cp "$@" "${INITRAMFS_TMP_S}"/etc/screens || die
}

pull_initramfs_binary() {
	# For busybox and sh
	idobin /bin/busybox
	ln -s busybox "${INITRAMFS_TMP_S}/bin/sh"

	# For verified rootfs
	idobin /sbin/dmsetup

	# For message screen display and progress bars
	idobin /usr/bin/ply-image
	idobin /usr/bin/pv
	idobin /usr/sbin/vpd

	# /usr/sbin/vpd invokes 'flashrom' via system()
	idobin /usr/sbin/flashrom

	# For recovery behavior
	idobin /usr/bin/futility
	idofutility /usr/bin/old_bins/cgpt
	idofutility /usr/bin/old_bins/crossystem
	idofutility /usr/bin/old_bins/dump_kernel_config
	idofutility /usr/bin/old_bins/tpmc
	idofutility /usr/bin/old_bins/vbutil_kernel

	# PNG image assets
	local shared_assets="${SYSROOT}"/usr/share/chromeos-assets
	insimage "${shared_assets}"/images/boot_message.png
	insimage "${S}"/assets/spinner_*.png
	insimage "${S}"/assets/icon_check.png
	insimage "${S}"/assets/icon_warning.png
	${S}/make_images "${S}/localized_text" \
					 "${INITRAMFS_TMP_S}/etc/screens" || die
}

pull_netboot_ramfs_binary() {
	# We want to keep GNU sh at /bin/sh, so let's change shebang for init
	# to busybox explicitly.
	sed -i '1s|.*|#!/bin/busybox sh\nset -x|' "${INITRAMFS_TMP_S}/init" || die

	# Busybox and utilities
	idobin /bin/busybox
	local bin_name
	local busybox_bins=(
		awk
		basename
		cat
		chmod
		chroot
		cp
		cut
		date
		dirname
		expr
		find
		grep
		gzip
		head
		id
		ifconfig
		ip
		mkdir
		mkfs.vfat
		mktemp
		modprobe
		mount
		rm
		rmdir
		route
		sed
		sleep
		stty
		sync
		tee
		tftp
		tr
		true
		udhcpc
		umount
		uname
		uniq
	)
	for bin_name in ${busybox_bins[@]}; do
		ln -s busybox "${INITRAMFS_TMP_S}/bin/${bin_name}" || die
	done

	#
	# Any new files added here must include dependencies in RDEPEND above.
	#

	# Factory installer
	# chromeos-base/chromeos-factoryinstall
	idobin /usr/sbin/factory_install.sh
	idobin /usr/sbin/netboot_postinst.sh
	idobin /usr/sbin/ping_shopfloor.sh
	idobin /usr/sbin/secure_less.sh
	# chromeos-base/chromeos-installer
	idobin /usr/sbin/chromeos-common.sh
	idobin /usr/sbin/chromeos-install
	# dev-util/shflags
	cp "${SYSROOT}"/usr/share/misc/shflags "${INITRAMFS_TMP_S}"/usr/share/misc

	# Binaries used by factory installer
	idobin /bin/bash
	idobin /bin/dd
	idobin /bin/sh
	idobin /bin/xxd
	idobin /sbin/blockdev
	idobin /sbin/fsck.vfat
	idobin /sbin/resize2fs
	idobin /sbin/sfdisk
	idofutility /usr/bin/old_bins/cgpt
	idofutility /usr/bin/old_bins/crossystem
	idobin /usr/bin/futility
	idobin /usr/bin/getopt
	idobin /usr/bin/openssl
	idobin /usr/bin/uudecode
	idobin /usr/bin/wget
	idobin /usr/sbin/flashrom
	idobin /usr/sbin/htpdate
	idobin /usr/sbin/lightup_screen
	idobin /usr/sbin/partprobe
	ln -s "/bin/cgpt" "${INITRAMFS_TMP_S}/usr/bin/cgpt" || die

	# Install ectool if there is one
	if [ -e "${SYSROOT}"/usr/sbin/ectool ]; then
		idobin /usr/sbin/ectool
	else
		einfo "Skipping ectool"
	fi

	# We don't need to display image. Create empty constants.sh so that
	# messages.sh doesn't freak out.
	touch "${INITRAMFS_TMP_S}/etc/screens/constants.sh"

	# Network support
	cp "${FILESDIR}"/udhcpc.script "${INITRAMFS_TMP_S}/etc" || die
	chmod +x "${INITRAMFS_TMP_S}/etc/udhcpc.script"

	# Create a dummy /etc/passwd with root and nobody.  This is
	# necessary to let processes drop privileges and become
	# nobody.  We use the same settings as in the root fs.
	cp "${FILESDIR}"/passwd "${INITRAMFS_TMP_S}/etc" || die
	chmod 400 "${INITRAMFS_TMP_S}/etc/passwd"

        # Create /var/empty as home directory for nobody user.
	mkdir -p "${INITRAMFS_TMP_S}/var/empty"

	# USB Ethernet kernel module
	USBNET_MOD_PATH=$(find "${SYSROOT}"/lib/modules/ -name usbnet.ko)
	[ -n "$USBNET_MOD_PATH" ] || die
	USBNET_DIR_PATH=$(dirname "${USBNET_MOD_PATH}")
	USBNET_INSTALL_PATH="${USBNET_DIR_PATH#${SYSROOT}}"
	mkdir -p "${INITRAMFS_TMP_S}/${USBNET_INSTALL_PATH}"
	while read module ; do
		cp -p "${module}" "${INITRAMFS_TMP_S}/${USBNET_INSTALL_PATH}/"
		einfo "Copied: ${module#${SYSROOT}}"
	done < <(find "${USBNET_DIR_PATH}" -name '*.ko')

	# Generates lsb-factory
	LSBDIR="mnt/stateful_partition/dev_image/etc"
	GENERATED_LSB_FACTORY="${INITRAMFS_TMP_S}/${LSBDIR}/lsb-factory"
	SERVER_ADDR="${SERVER_ADDR-10.0.0.1}"
	BOARD="$(get_current_board_with_variant)"
	mkdir -p "${INITRAMFS_TMP_S}/${LSBDIR}"
	cat "${FILESDIR}"/lsb-factory.template | \
		sed "s/%BOARD%/${BOARD}/g" |
		sed "s/%SERVER_ADDR%/${SERVER_ADDR}/g" \
		>"${GENERATED_LSB_FACTORY}"
	ln -s "/$LSBDIR/lsb-factory" "${INITRAMFS_TMP_S}/etc/lsb-release"

	# Partition table
	cp "${SYSROOT}"/root/.gpt_layout "${INITRAMFS_TMP_S}"/root/
	cp "${SYSROOT}"/root/.pmbr_code "${INITRAMFS_TMP_S}"/root/

	# Generates write_gpt.sh
	INSTALLED_SCRIPT="${INITRAMFS_TMP_S}"/usr/sbin/write_gpt.sh
	BOARD=$(get_current_board_with_variant)
	. "${BUILD_LIBRARY_DIR}"/disk_layout_util.sh || die
	write_partition_script usb "${INSTALLED_SCRIPT}" || die

	# Install Memento updater
	idoexe '/opt/google/memento_updater/*'
}

build_initramfs_file() {
	local dir

	local subdirs=(
		bin
		bin/old_bins
		dev
		etc
		etc/screens
		lib
		log
		newroot
		proc
		root
		stateful
		sys
		tmp
		usb
		usr/bin
		usr/sbin
		usr/share/misc
	)
	for dir in ${subdirs[@]}; do
		mkdir -p "${INITRAMFS_TMP_S}/$dir" || die
	done

	# On amd64, shared libraries must live in /lib64.  More generally,
	# $(get_libdir) tells us the directory name we need for the target
	# platform's libraries.  The 'copy_elf' script installs in /lib; to
	# keep that script simple we just create a symlink to /lib, if
	# necessary.
	local libdir=$(get_libdir)
	if [ "${libdir}" != "lib" ]; then
		ln -s lib "${INITRAMFS_TMP_S}/${libdir}"
	fi

	# Copy source files not merged from our dependencies.
	cp "${S}"/init "${INITRAMFS_TMP_S}/init" || die
	chmod +x "${INITRAMFS_TMP_S}/init"
	cp "${S}"/*.sh "${INITRAMFS_TMP_S}/lib" || die

	if use netboot_ramfs; then
		pull_netboot_ramfs_binary
	else
		pull_initramfs_binary
	fi

	# The kernel emake expects the file in cpio format.
	( cd "${INITRAMFS_TMP_S}"
	  find . | cpio -o -H newc |
		xz -9 --check=crc32 > \
		"${WORKDIR}/${INITRAMFS_FILE}" ) ||
		die "cannot package initramfs"
}

src_compile() {
	INITRAMFS_TMP_S=${WORKDIR}/initramfs_tmp
	if use netboot_ramfs; then
		INITRAMFS_FILE="netboot_ramfs.cpio.xz"
	else
		INITRAMFS_FILE="initramfs.cpio.xz"
	fi

	einfo "Creating ${INITRAMFS_FILE}"
	build_initramfs_file
	INITRAMFS_FILE_SIZE=$(stat --printf="%s" "${WORKDIR}/${INITRAMFS_FILE}")
	einfo "${INITRAMFS_FILE}: ${INITRAMFS_FILE_SIZE} bytes"
}

src_install() {
	insinto /var/lib/misc
	doins "${WORKDIR}/${INITRAMFS_FILE}"
}
