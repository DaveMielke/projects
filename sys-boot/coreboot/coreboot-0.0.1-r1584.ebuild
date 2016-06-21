# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT=("a61b11b2b32f09b43b79bc7693a9b50faa3f70de" "a7e530331d7cf4b58618f0715e61b5a872176f07" "05cd8ce75f97a76c4ef155734d191cd275bac231" "9ba07035ed0acb28902cce826ea833cf531d57c1" "b7d5b2d6a6dd05874d86ee900ff441d261f9034c")
CROS_WORKON_TREE=("a1129d5823bbf34478b8023a053ecdb30dd9f0d2" "b8f1fcb1b1a9e2ba1e18cc09f70be3046cac2bb8" "92b9b7ba98aa165f57ca7f29729435fef3e10db4" "f78a5cfb57197350a309e2d2a93b09fe308f9c5f" "c0433b88f972fa26dded401be022c1c026cd644e")
CROS_WORKON_PROJECT=(
	"chromiumos/third_party/coreboot"
	"chromiumos/third_party/arm-trusted-firmware"
	"chromiumos/platform/vboot_reference"
	"chromiumos/third_party/coreboot/blobs"
	"chromiumos/third_party/cbootimage"
)
CROS_WORKON_LOCALNAME=(
	"coreboot"
	"arm-trusted-firmware"
	"../platform/vboot_reference"
	"coreboot/3rdparty/blobs"
	"cbootimage"
)
CROS_WORKON_DESTDIR=(
	"${S}"
	"${S}/3rdparty/arm-trusted-firmware"
	"${S}/3rdparty/vboot"
	"${S}/3rdparty/blobs"
	"${S}/util/nvidia/cbootimage"
)

inherit cros-board cros-workon toolchain-funcs

DESCRIPTION="coreboot firmware"
HOMEPAGE="http://www.coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="em100-mode fsp memmaps mocktpm quiet-cb rmt vmx mtc mma"
IUSE="${IUSE} +bmpblk bitmap_in_cbfs cros_ec pd_sync depthcharge qca-framework"

PER_BOARD_BOARDS=(
	bayleybay beltino bolt butterfly chell cyan daisy falco fox gizmo glados
	kunimitsu link lumpy nyan panther parrot peppy rambi samus sklrvp
	slippy stout stout32 strago stumpy urara variant-peach-pit
)

DEPEND_BLOCKERS="${PER_BOARD_BOARDS[@]/#/!sys-boot/chromeos-coreboot-}"

RDEPEND="
	${DEPEND_BLOCKERS}
	!virtual/chromeos-coreboot
	"

# Dependency shared by x86 and amd64.
DEPEND_X86="
	sys-power/iasl
	sys-boot/chromeos-mrc
	"
DEPEND="
	mtc? ( sys-boot/mtc )
	chromeos-base/vboot_reference
	${DEPEND_BLOCKERS}
	virtual/coreboot-private-files
	sys-apps/coreboot-utils
	bmpblk? ( sys-boot/chromeos-bmpblk )
	cros_ec? ( chromeos-base/chromeos-ec )
	pd_sync? ( chromeos-base/chromeos-ec )
	x86? ($DEPEND_X86)
	amd64? ($DEPEND_X86)
	qca-framework? ( sys-boot/qca-framework )
	"

src_prepare() {
	local froot="${SYSROOT}/firmware"
	local privdir="${SYSROOT}/firmware/coreboot-private"
	local file

	if [[ -d "${privdir}" ]]; then
		while read -d $'\0' -r file; do
			rsync --recursive --links --executability --ignore-existing \
			      "${file}" ./ || die
		done < <(find "${privdir}" -maxdepth 1 -mindepth 1 -print0)
	fi

	for blob in mrc.bin mrc.elf efi.elf; do
		if [[ -r "${SYSROOT}/firmware/${blob}" ]]; then
			cp "${SYSROOT}/firmware/${blob}" 3rdparty/blobs/
		fi
	done

	local board=$(get_current_board_with_variant)
	if [[ ! -s "${FILESDIR}/configs/config.${board}" ]]; then
		board=$(get_current_board_no_variant)
	fi

	if use fsp; then
		if [[ -s "${FILESDIR}/configs/config.${board}.fsp" ]]; then
			elog "   - using fsp config"
			board=${board}.fsp
		fi
	fi

	if [[ -s "${FILESDIR}/configs/config.${board}" ]]; then

		emake clean  # in case someone tried a local make, ensure
			     # there is no leftovers

		cp -v "${FILESDIR}/configs/config.${board}" .config

		# Override mainboard vendor if needed.
		if [[ -n "${SYSTEM_OEM}" ]]; then
			echo "CONFIG_MAINBOARD_VENDOR=\"${SYSTEM_OEM}\"" >> .config
		fi

		# In case config comes from a symlink we are likely building
		# for an overlay not matching this config name. Enable adding
		# a CBFS based board ID for coreboot.
		if [[ -L "${FILESDIR}/configs/config.${board}" ]]; then
			echo "CONFIG_BOARD_ID_MANUAL=y" >> .config
			echo "CONFIG_BOARD_ID_STRING=\"${BOARD_USE}\"" >> .config
		fi
	fi

	if use rmt; then
		echo "CONFIG_MRC_RMT=y" >> .config
	fi
	if use vmx; then
		elog "   - enabling VMX"
		echo "CONFIG_ENABLE_VMX=y" >> .config
	fi
	if use quiet-cb; then
		# Suppress console spew if requested.
		cat >> .config <<EOF
CONFIG_DEFAULT_CONSOLE_LOGLEVEL=3
# CONFIG_DEFAULT_CONSOLE_LOGLEVEL_8 is not set
CONFIG_DEFAULT_CONSOLE_LOGLEVEL_3=y
EOF
	fi
	if use mocktpm; then
		echo "CONFIG_VBOOT2_MOCK_SECDATA=y" >> .config
	fi
	if use mma; then
		echo "CONFIG_MMA=y" >> .config
	fi

	if use bmpblk && ! use bitmap_in_cbfs; then
		echo "CONFIG_GBB_BMPFV_FILE=\"${froot}/bmpblk.bin\"" >> .config
	fi

	# disable coreboot's own EC firmware building mechanism
	echo "CONFIG_EC_EXTERNAL_FIRMWARE=y" >> .config

	cp .config .config_serial
	# handle the case when .config does not have a newline in the end.
	echo >> .config_serial
	cat "${FILESDIR}/configs/fwserial.${board}" >> .config_serial || die
	echo "CONFIG_GBB_FLAG_ENABLE_SERIAL=y" >> .config_serial
}

add_ec() {
	local rom="$1"
	local name="$2"
	local ecroot="$3"

	cbfstool "${rom}" add -r FW_MAIN_A,FW_MAIN_B -t raw -c lzma \
		 -f "${ecroot}/ec.RW.bin" -n "${name}" || die
	cbfstool "${rom}" add -r FW_MAIN_A,FW_MAIN_B -t raw -c none \
		 -f "${ecroot}/ec.RW.hash" -n "${name}.hash" || die
}

make_coreboot() {
	local builddir="$1"
	local froot="${SYSROOT}/firmware"

	yes "" | emake oldconfig obj="${builddir}"
	emake obj="${builddir}"

	# Modify firmware descriptor if building for the EM100 emulator.
	if use em100-mode; then
		ifdtool --em100 "${builddir}/coreboot.rom" || die
		mv "${builddir}/coreboot.rom"{.new,} || die
	fi

	if ! use depthcharge; then
		# pre-depthcarge builds don't know our new CBFS-based world,
		# so the following image changes aren't relevant for them.
		return
	fi

	if use cros_ec; then
		add_ec "${builddir}/coreboot.rom" "ecrw" "${froot}"
	fi

	if use pd_sync; then
		add_ec "${builddir}/coreboot.rom" "pdrw" "${froot}/${PD_FIRMWARE}"
	fi

	( cd "${froot}/cbfs" 2>/dev/null && find . -type f) | \
	while read file; do
		file="${file:2}" # strip ./ prefix
		cbfstool "${builddir}/coreboot.rom" add \
			-r COREBOOT,FW_MAIN_A,FW_MAIN_B \
			-f "${froot}/cbfs/$file" \
			-n "$file" \
			-t raw -c lzma
	done
}

src_compile() {
	tc-export CC

	# Set KERNELREVISION (really coreboot revision) to the ebuild revision
	# number followed by a dot and the first seven characters of the git
	# hash. The name is confusing but consistent with the coreboot
	# Makefile.
	local sha1v="${VCSID/*-/}"
	export KERNELREVISION=".${PV}.${sha1v:0:7}"

	# Export the known cross compilers so there isn't a reliance
	# on what the default profile is for exporting a compiler. The
	# reasoning is that the firmware may need more than one to build
	# and boot.
	export CROSS_COMPILE_i386="i686-pc-linux-gnu-"
	# For coreboot.org upstream architecture naming.
	export CROSS_COMPILE_x86="i686-pc-linux-gnu-"
	export CROSS_COMPILE_mipsel="mipsel-cros-linux-gnu-"
	# aarch64: used on chromeos-2013.04
	export CROSS_COMPILE_aarch64="aarch64-cros-linux-gnu-"
	# arm64: used on coreboot upstream
	export CROSS_COMPILE_arm64="aarch64-cros-linux-gnu-"
	export CROSS_COMPILE_arm="armv7a-cros-linux-gnu- armv7a-cros-linux-gnueabi-"

	elog "Toolchain:\n$(sh util/xcompile/xcompile)\n"

	make_coreboot "build"

	# Build a second ROM with serial support for developers
	mv .config_serial .config
	make_coreboot "build_serial"
}

src_install() {
	local mapfile
	local board=$(get_current_board_with_variant)
	if [[ ! -s "${FILESDIR}/configs/config.${board}" ]]; then
		board=$(get_current_board_no_variant)
	fi

	if use fsp; then
		if [[ -s "${FILESDIR}/configs/config.${board}.fsp" ]]; then
			elog "   - using fsp config"
			board=${board}.fsp
		fi
	fi

	insinto /firmware

	newins "build/coreboot.rom" coreboot.rom
	newins "build_serial/coreboot.rom" coreboot.rom.serial

	OPROM=$( awk 'BEGIN{FS="\""} /CONFIG_VGA_BIOS_FILE=/ { print $2 }' \
		${FILESDIR}/configs/config.${board} )
	CBFSOPROM=pci$( awk 'BEGIN{FS="\""} /CONFIG_VGA_BIOS_ID=/ { print $2 }' \
		${FILESDIR}/configs/config.${board} ).rom
	FSP=$( awk 'BEGIN{FS="\""} /CONFIG_FSP_FILE=/ { print $2 }' \
		${FILESDIR}/configs/config.${board} )
	if [[ -n "${FSP}" ]]; then
		newins ${FSP} fsp.bin
	fi
	if [[ -n "${OPROM}" ]]; then
		newins ${OPROM} ${CBFSOPROM}
	fi
	if use memmaps; then
		for mapfile in build/cbfs/fallback/*.map
		do
			doins $mapfile
		done
	fi
	newins .config coreboot.config

	# Keep binaries with debug symbols around for crash dump analysis
	insinto /firmware/coreboot
	doins build/cbfs/fallback/*.debug
	insinto /firmware/coreboot_serial
	doins build_serial/cbfs/fallback/*.debug
}
