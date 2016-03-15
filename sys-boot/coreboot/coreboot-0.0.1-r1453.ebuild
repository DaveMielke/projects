# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT=("f059f39a0f5c2f21e564b9554efacf26a41ad794" "85320724af73d0015d2cb0e99d59c292290b6ce5" "65f61f90ccae5f0b5f37ea3bdf86735bc58709a0" "9ba07035ed0acb28902cce826ea833cf531d57c1" "b7d5b2d6a6dd05874d86ee900ff441d261f9034c")
CROS_WORKON_TREE=("937751d7a61cc7cce44f435bd1fa098c11218ba4" "7522e4965dff67e7a1a58aa5a7cdfa7daf25716d" "60c1112de026c06994c10c5199050c547a30c224" "f78a5cfb57197350a309e2d2a93b09fe308f9c5f" "c0433b88f972fa26dded401be022c1c026cd644e")
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

PER_BOARD_BOARDS=(
	bayleybay beltino bolt butterfly chell cyan daisy falco fox gizmo glados
	kunimitsu lars link lumpy nyan panther parrot peppy rambi samus sklrvp
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
	x86? ($DEPEND_X86)
	amd64? ($DEPEND_X86)
	"

VERIFIED_STAGES=( "ramstage" "romstage" "refcode" "bl31" "secure_os" )

src_prepare() {
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

	cp .config .config_serial
	# handle the case when .config does not have a newline in the end.
	echo >> .config_serial
	cat "${FILESDIR}/configs/fwserial.${board}" >> .config_serial || die
}

make_coreboot() {
	local builddir="$1"

	yes "" | emake oldconfig obj="${builddir}"
	emake obj="${builddir}"

	# Modify firmware descriptor if building for the EM100 emulator.
	if use em100-mode; then
		ifdtool --em100 "${builddir}/coreboot.rom" || die
		mv "${builddir}/coreboot.rom"{.new,} || die
	fi

	# Extract stages which may need to be repackaged for vboot, if present.
	for stage in ${VERIFIED_STAGES[@]}; do
		cbfstool "${builddir}/coreboot.rom" extract \
			-n "fallback/${stage}" \
			-f "${builddir}/${stage}.stage" || true
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
	for stage in ${VERIFIED_STAGES[@]}; do
		if [[ -f "build/${stage}.stage" ]]; then
			newins "build/${stage}.stage" "${stage}.stage"
			newins "build_serial/${stage}.stage" "${stage}.stage.serial"
		fi
		if [[ -f "build/cbfs/fallback/${stage}.elf" ]]; then
			newins "build/cbfs/fallback/${stage}.elf" "${stage}.elf"
			newins "build_serial/cbfs/fallback/${stage}.elf" "${stage}.elf.serial"
		fi
	done

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
}
