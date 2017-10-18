# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# Change this version number when any change is made to configs/files under
# coreboot and an auto-revbump is required.
# VERSION=REVBUMP-0.0.7

EAPI=4
CROS_WORKON_COMMIT=("48d4f06887f34dff3465829604268356e3ed0470" "f18f5f9867551d0d21da79e25371a298933aaff1" "0329f9c2ec6a1ab951ad06d12e7706d63f6f0d8f" "a3576d16e98a2e0760eb97771062ae5e931e748e" "b7d5b2d6a6dd05874d86ee900ff441d261f9034c")
CROS_WORKON_TREE=("604981a6db969f7c6123f33047a5958b4ce73f90" "3f4c8c34f2cabb6defdab8389a592c9efe885a0c" "71ef8f85b94604d57511df31c7e4adf13f21de56" "4ff07a9d25411c220160fe1735327b13abeeb93c" "c0433b88f972fa26dded401be022c1c026cd644e")
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

inherit cros-board cros-workon toolchain-funcs cros-unibuild

DESCRIPTION="coreboot firmware"
HOMEPAGE="http://www.coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="em100-mode fastboot fsp memmaps mocktpm quiet-cb rmt vmx mtc mma"
IUSE="${IUSE} +bmpblk cros_ec +intel_mrc pd_sync qca-framework quiet unibuild verbose"
IUSE="${IUSE} coreboot-sdk"

PER_BOARD_BOARDS=(
	bayleybay beltino bolt butterfly chell cyan daisy eve falco
	fizz fox glados kahlee kunimitsu link lumpy nyan panther
	parrot peppy poppy rambi samus sklrvp slippy stout stout32
	strago stumpy urara variant-peach-pit
)

DEPEND_BLOCKERS="${PER_BOARD_BOARDS[@]/#/!sys-boot/chromeos-coreboot-}"

RDEPEND="
	${DEPEND_BLOCKERS}
	!virtual/chromeos-coreboot
	"

# Dependency shared by x86 and amd64.
DEPEND_X86="
	sys-power/iasl
	intel_mrc? ( sys-boot/chromeos-mrc )
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
	unibuild? ( chromeos-base/chromeos-config )
	"

# Get the coreboot board config to build for.
# Checks the current board with/without variant, and also whether an FSP
# is in use. Echoes the board config file that should be used to build
# coreboot.
get_board() {
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
	echo "${board}"
}

get_model_build_targets() {
	echo $( get_unique_model_conf_value_set /firmware/build-targets coreboot )
}

set_build_env() {
	BOARD="$1"

	if use unibuild; then
		CONFIG=".config-${BOARD}"
		CONFIG_SERIAL=".config_serial-${BOARD}"
		BUILD_DIR="build-${BOARD}"
		BUILD_DIR_SERIAL="build_serial-${BOARD}"
	else
		CONFIG=".config"
		CONFIG_SERIAL=".config_serial"
		BUILD_DIR="build"
		BUILD_DIR_SERIAL="build_serial"
	fi
}

# Create the coreboot configuration files for a particular board. This
# creates a standard config and a serial config.
# Args:
#   $1: Name of board to create a configure file for (e.g. "reef")
#   $2: Base board name, if any (used for unified builds)
create_config() {
	local base_board="$2"

	set_build_env "$1"

	if [[ -s "${FILESDIR}/configs/config.${BOARD}" ]]; then

		cp -v "${FILESDIR}/configs/config.${BOARD}" "${CONFIG}"

		# Override mainboard vendor if needed.
		if [[ -n "${SYSTEM_OEM}" ]]; then
			echo "CONFIG_MAINBOARD_VENDOR=\"${SYSTEM_OEM}\"" >> "${CONFIG}"
		fi

		# In case config comes from a symlink we are likely building
		# for an overlay not matching this config name. Enable adding
		# a CBFS based board ID for coreboot.
		if [[ -L "${FILESDIR}/configs/config.${BOARD}" ]]; then
			echo "CONFIG_BOARD_ID_MANUAL=y" >> "${CONFIG}"
			echo "CONFIG_BOARD_ID_STRING=\"${BOARD_USE}\"" >> "${CONFIG}"
		fi
	fi

	if use rmt; then
		echo "CONFIG_MRC_RMT=y" >> "${CONFIG}"
	fi
	if use vmx; then
		elog "   - enabling VMX"
		echo "CONFIG_ENABLE_VMX=y" >> "${CONFIG}"
	fi
	if use quiet-cb; then
		# Suppress console spew if requested.
		cat >> "${CONFIG}" <<EOF
CONFIG_DEFAULT_CONSOLE_LOGLEVEL=3
# CONFIG_DEFAULT_CONSOLE_LOGLEVEL_8 is not set
CONFIG_DEFAULT_CONSOLE_LOGLEVEL_3=y
EOF
	fi
	if use mocktpm; then
		echo "CONFIG_VBOOT_MOCK_SECDATA=y" >> "${CONFIG}"
	fi
	if use mma; then
		echo "CONFIG_MMA=y" >> "${CONFIG}"
	fi

	# allow using non-coreboot toolchains
	echo "CONFIG_ANY_TOOLCHAIN=y" >> "${CONFIG}"
	# disable coreboot's own EC firmware building mechanism
	echo "CONFIG_EC_GOOGLE_CHROMEEC_FIRMWARE_NONE=y" >> "${CONFIG}"
	echo "CONFIG_EC_GOOGLE_CHROMEEC_PD_FIRMWARE_NONE=y" >> "${CONFIG}"
	# enable common GBB flags for development
	echo "CONFIG_GBB_FLAG_DEV_SCREEN_SHORT_DELAY=y" >> "${CONFIG}"
	echo "CONFIG_GBB_FLAG_DISABLE_FW_ROLLBACK_CHECK=y" >> "${CONFIG}"
	echo "CONFIG_GBB_FLAG_FORCE_DEV_BOOT_USB=y" >> "${CONFIG}"
	echo "CONFIG_GBB_FLAG_FORCE_DEV_SWITCH_ON=y" >> "${CONFIG}"
	if use fastboot; then
		echo "CONFIG_GBB_FLAG_FORCE_DEV_BOOT_FASTBOOT_FULL_CAP=y" >> "${CONFIG}"
	fi
	local version=$(${CHROOT_SOURCE_ROOT}/src/third_party/chromiumos-overlay/chromeos/config/chromeos_version.sh |grep "^[[:space:]]*CHROMEOS_VERSION_STRING=" |cut -d= -f2)
	echo "CONFIG_VBOOT_FWID_VERSION=\".${version}\"" >> "${CONFIG}"

	cp "${CONFIG}" "${CONFIG_SERIAL}"
	# handle the case when "${CONFIG}" does not have a newline in the end.
	echo >> "${CONFIG_SERIAL}"
	file="${FILESDIR}/configs/fwserial.${BOARD}"
	if [ ! -f "${file}" ] && [ -n "${base_board}" ]; then
		file="${FILESDIR}/configs/fwserial.${base_board}"
	fi
	if [ ! -f "${file}" ]; then
		file="${FILESDIR}/configs/fwserial.default"
	fi
	cat "${file}" >> "${CONFIG_SERIAL}" || die
	echo "CONFIG_GBB_FLAG_ENABLE_SERIAL=y" >> "${CONFIG_SERIAL}"

	einfo "Configured ${CONFIG} for board ${BOARD} in ${BUILD_DIR}"
}

src_prepare() {
	local froot="${SYSROOT}/firmware"
	local privdir="${SYSROOT}/firmware/coreboot-private"
	local file

	if [[ -d "${privdir}" ]]; then
		while read -d $'\0' -r file; do
			rsync --recursive --links --executability \
				"${file}" ./ || die
		done < <(find "${privdir}" -maxdepth 1 -mindepth 1 -print0)
	fi

	for blob in mrc.bin mrc.elf efi.elf; do
		if [[ -r "${SYSROOT}/firmware/${blob}" ]]; then
			cp "${SYSROOT}/firmware/${blob}" 3rdparty/blobs/
		fi
	done

	if use unibuild; then
		local build_target

		for build_target in $(get_model_build_targets); do
			create_config "${build_target}" "$(get_board)"
		done
	else
		create_config "$(get_board)"
	fi
}

add_ec() {
	local rom="$1"
	local name="$2"
	local ecroot="$3"

	cbfstool "${rom}" add -r FW_MAIN_A,FW_MAIN_B -t raw -c lzma \
		-f "${ecroot}/ec.RW.bin" -n "${name}" || return 1
	cbfstool "${rom}" add -r FW_MAIN_A,FW_MAIN_B -t raw -c none \
		-f "${ecroot}/ec.RW.hash" -n "${name}.hash" || return 1
}

add_fw_blob() {
	local rom="$1"
	local cbname="$2"
	local blob="$3"
	local cbhash="${cbname%.bin}.hash"
	local hash="${blob%.bin}.hash"

	cbfstool "${rom}" add -r FW_MAIN_A,FW_MAIN_B -t raw -c lzma \
		-f "${blob}" -n "${cbname}" || die
	cbfstool "${rom}" add -r FW_MAIN_A,FW_MAIN_B -t raw -c none \
		-f "${hash}" -n "${cbhash}" || die
}

# Build coreboot with a supplied configuration and output directory.
#   $1: Build directory to use (e.g. "build_serial")
#   $2: Config file to use (e.g. ".config_serial")
#   $3: Build target build (e.g. "pyro"), for USE=unibuild only.
make_coreboot() {
	local builddir="$1"
	local config_fname="$2"
	local build_target="$3"
	local froot="${SYSROOT}/firmware"
	local fblobroot="${SYSROOT}/firmware"

	if use unibuild; then
		froot+="/${build_target}"
	fi
	rm -rf "${builddir}" .xcompile

	local CB_OPTS=( "objutil=objutil" "DOTCONFIG=${config_fname}" )
	use quiet && CB_OPTS+=( "V=0" )
	use verbose && CB_OPTS+=( "V=1" )
	use quiet && REDIR="/dev/null" || REDIR="/dev/stdout"

	# Configure and build coreboot.
	yes "" | emake oldconfig "${CB_OPTS[@]}" obj="${builddir}" >${REDIR}
	emake "${CB_OPTS[@]}" obj="${builddir}"

	# Expand FW_MAIN_* since we might add some files
	cbfstool "${builddir}/coreboot.rom" expand -r FW_MAIN_A,FW_MAIN_B

	# Record the config that we used.
	cp "${config_fname}" "${builddir}/${config_fname}"

	# Modify firmware descriptor if building for the EM100 emulator.
	if use em100-mode; then
		ifdtool --em100 "${builddir}/coreboot.rom" || die
		mv "${builddir}/coreboot.rom"{.new,} || die
	fi

	if use cros_ec; then
		add_ec "${builddir}/coreboot.rom" "ecrw" "${froot}"

		if [[ $? -ne 0 ]]; then
			# This might be a unibuild model which only exists on
			# other firmware branches. Only die if this is not
			# unibuild.
			if ! use unibuild; then
				die "Could not add EC in '${froot}' to Coreboot"
			fi

			# Try to find another EC in this family to install (for
			# ToT build validation). Technically, this may not work
			# for the currently-targetted model but this does at
			# least validate that cbfstool properly incorporates
			# a blob for this model.
			local ec_found=false
			local other_model

			for other_model in $(get_model_list); do
				local other_froot="${SYSROOT}/firmware\
/${other_model}"

				if [[ -e "${other_froot}/ec.RW.bin" ]]; then
					ec_found=true
					add_ec "${builddir}/coreboot.rom" \
						"ecrw" \
						"${other_froot}" || die
					break
				fi
			done

			if [[ ${ec_found} == false ]]; then
				die "We were not able to find an EC target \
to include from the set '${get_model_list[*]}'"
			fi
		fi
	fi

	if use pd_sync; then
		add_ec "${builddir}/coreboot.rom" "pdrw" \
			"${froot}/${PD_FIRMWARE}" ||
			die "Could not add PD in '${froot}/${PD_FIRMWARE}' \
to Coreboot"
	fi

	local blob
	local cbname
	for blob in ${FW_BLOBS}; do
		cbname=$(basename "${blob}")
		add_fw_blob "${builddir}/coreboot.rom" "${cbname}" \
			"${fblobroot}/${blob}" || die
	done

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
	# Set KERNELREVISION (really coreboot revision) to the ebuild revision
	# number followed by a dot and the first seven characters of the git
	# hash. The name is confusing but consistent with the coreboot
	# Makefile.
	local sha1v="${VCSID/*-/}"
	export KERNELREVISION=".${PV}.${sha1v:0:7}"

	if ! use coreboot-sdk; then
		tc-export CC
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
	else
		export XGCCPATH=/opt/coreboot-sdk/bin/
	fi

	use verbose && elog "Toolchain:\n$(sh util/xcompile/xcompile)\n"

	# Build a second ROM with serial support for developers.
	if use unibuild; then
		local build_target

		for build_target in $(get_model_build_targets); do
			set_build_env "${build_target}"
			make_coreboot "${BUILD_DIR}" "${CONFIG}" "${build_target}"
			make_coreboot "${BUILD_DIR_SERIAL}" "${CONFIG_SERIAL}" \
				"${build_target}"
		done
	else
		set_build_env "$(get_board)"
		make_coreboot "${BUILD_DIR}" "${CONFIG}"
		make_coreboot "${BUILD_DIR_SERIAL}" "${CONFIG_SERIAL}"
	fi
}

do_install() {
	local build_target="$1"
	local dest_dir="/firmware"
	local mapfile

	if [[ -n "${build_target}" ]]; then
		dest_dir+="/${build_target}"
		einfo "Installing coreboot ${build_target} into ${dest_dir}"
	fi
	insinto "${dest_dir}"

	newins "${BUILD_DIR}/coreboot.rom" coreboot.rom
	newins "${BUILD_DIR_SERIAL}/coreboot.rom" coreboot.rom.serial

	local config_file="${FILESDIR}/configs/config.$(get_board)"
	OPROM=$( awk 'BEGIN{FS="\""} /CONFIG_VGA_BIOS_FILE=/ { print $2 }' \
		"${config_file}" )
	CBFSOPROM=pci$( awk 'BEGIN{FS="\""} /CONFIG_VGA_BIOS_ID=/ { print $2 }' \
		"${config_file}" ).rom
	FSP=$( awk 'BEGIN{FS="\""} /CONFIG_FSP_FILE=/ { print $2 }' \
		"${config_file}" )
	if [[ -n "${FSP}" ]]; then
		newins ${FSP} fsp.bin
	fi
	if [[ -n "${OPROM}" ]]; then
		newins ${OPROM} ${CBFSOPROM}
	fi
	if use memmaps; then
		for mapfile in "${BUILD_DIR}"/cbfs/fallback/*.map
		do
			doins $mapfile
		done
	fi
	newins "${BUILD_DIR}/${CONFIG}" coreboot.config
	newins "${BUILD_DIR_SERIAL}/${CONFIG_SERIAL}" coreboot_serial.config

	# Keep binaries with debug symbols around for crash dump analysis
	if [[ -s "${BUILD_DIR}/bl31.elf" ]]; then
		newins "${BUILD_DIR}/bl31.elf" bl31.elf
		newins "${BUILD_DIR}/bl31.elf" bl31.serial.elf
	fi
	insinto "${dest_dir}"/coreboot
	doins "${BUILD_DIR}"/cbfs/fallback/*.debug
	insinto "${dest_dir}"/coreboot_serial
	doins "${BUILD_DIR_SERIAL}"/cbfs/fallback/*.debug
}

src_install() {
	local build_target

	if use unibuild; then
		for build_target in $(get_model_build_targets); do
			set_build_env "${build_target}" "$(get_board)"
			do_install ${build_target}
		done
	else
		set_build_env "$(get_board)"
		do_install
	fi
}
