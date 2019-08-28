# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="708524f4c8cf09109eb71efa1bead137d2d4f995"
CROS_WORKON_TREE="73947b1ec936ba3ac81828333f4e356158277418"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_PROJECT="chromiumos/platform/vboot_reference"

inherit cros-debug cros-workon

DESCRIPTION="Chrome OS verified boot tools"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host dev_debug_force fuzzer pd_sync tpmtests tpm tpm2"

REQUIRED_USE="tpm2? ( !tpm )"

RDEPEND="cros_host? ( dev-libs/libyaml )
	dev-libs/libzip:=
	dev-libs/openssl:=
	sys-apps/util-linux"
DEPEND="${RDEPEND}"

src_configure() {
	cros-workon_src_configure
}

vemake() {
	emake \
		SRCDIR="${S}" \
		LIBDIR="$(get_libdir)" \
		ARCH=$(tc-arch) \
		TPM2_MODE=$(usev tpm2) \
		PD_SYNC=$(usev pd_sync) \
		MINIMAL=$(usev !cros_host) \
		NO_BUILD_TOOLS=$(usev fuzzer) \
		DEV_DEBUG_FORCE=$(usev dev_debug_force) \
		"$@"
}

src_compile() {
	mkdir "${WORKDIR}"/build-main
	tc-export CC AR CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	# Vboot reference knows the flags to use
	unset CFLAGS
	vemake BUILD="${WORKDIR}"/build-main all
}

src_test() {
	! use amd64 && ! use x86 && ewarn "Skipping unittests for non-x86" && return 0
	vemake BUILD="${WORKDIR}"/build-main runtests
}

src_install() {
	einfo "Installing programs"
	vemake \
		BUILD="${WORKDIR}"/build-main \
		DESTDIR="${D}$(usex cros_host /usr '')" \
		install

	if use cros_host; then
		# Installing on the host
		exeinto /usr/share/vboot/bin
		doexe scripts/image_signing/*.sh

		# Remove board stuff.
		rm -r \
			"${D}"/usr/default \
			"${D}"/usr/bin/chromeos-tpm-recovery \
			"${D}"/usr/bin/dev_debug_vboot \
			"${D}"/usr/bin/enable_dev_usb_boot \
			"${D}"/usr/bin/load_kernel_test \
			"${D}"/usr/bin/make_dev_firmware.sh \
			"${D}"/usr/bin/make_dev_ssd.sh \
			"${D}"/usr/bin/tpm-nvsize \
			"${D}"/usr/bin/tpmc \
			|| die
	fi

	if use tpmtests; then
		into /usr
		# copy files starting with tpmtest, but skip .d files.
		dobin "${WORKDIR}"/build-main/tests/tpm_lite/tpmtest*[^.]?
		dobin "${WORKDIR}"/build-main/utility/tpm_set_readsrkpub
	fi

	# Install devkeys to /usr/share/vboot/devkeys
	# (shared by host and target)
	einfo "Installing devkeys"
	insinto /usr/share/vboot/devkeys
	doins tests/devkeys/*

	# Install public headers to /build/${BOARD}/usr/include/vboot
	einfo "Installing header files"
	insinto /usr/include/vboot
	doins host/include/* \
		firmware/include/gpt.h \
		firmware/include/tlcl.h \
		firmware/include/tss_constants.h \
		firmware/include/tpm1_tss_constants.h \
		firmware/include/tpm2_tss_constants.h \
		firmware/2lib/include/2id.h \
		firmware/lib21/include/vb21_struct.h

	einfo "Installing host library"
	dolib.a "${WORKDIR}"/build-main/libvboot_host.a
}
