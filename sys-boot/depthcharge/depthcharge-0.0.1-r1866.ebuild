# Copyright 2012 The Chromium OS Authors.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT=("2e5bb44eec253c47414e6ef092f44e61d87cdb52" "509339ce2b7499ccb90331ab6910b87d0f9889a5")
CROS_WORKON_TREE=("5d65088141ca181821c423fbcf2ef3c9ceb72d87" "ae383dbba8fb40b45db2a3dfcf15b0cfabf7ac25")
CROS_WORKON_PROJECT=(
	"chromiumos/platform/depthcharge"
	"chromiumos/platform/vboot_reference"
)

DESCRIPTION="coreboot's depthcharge payload"
HOMEPAGE="http://www.coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="detachable_ui fastboot fwconsole mocktpm pd_sync unibuild"

DEPEND="
	sys-boot/libpayload
	unibuild? ( chromeos-base/chromeos-config )
"

CROS_WORKON_LOCALNAME=("../platform/depthcharge" "../platform/vboot_reference")
VBOOT_REFERENCE_DESTDIR="${S}/vboot_reference"
CROS_WORKON_DESTDIR=("${S}" "${VBOOT_REFERENCE_DESTDIR}")

# Don't strip to ease remote GDB use (cbfstool strips final binaries anyway)
STRIP_MASK="*"

inherit cros-workon cros-board toolchain-funcs cros-unibuild

get_model_build_targets() {
	echo $(get_each_model_conf_value_set /firmware/build-targets depthcharge)
}

src_configure() {
	cros-workon_src_configure
}

# Get the depthcharge board config to build for.
# Checks the current board with/without variant. Echoes the board config file
# that should be used to build depthcharge.
get_board() {
	local board=$(get_current_board_with_variant)
	if [[ ! -d "board/${board}" ]]; then
		board=$(get_current_board_no_variant)
	fi

	echo "${board}"
}

# Build depthcharge with common options.
# Usage example: dc_make dev LIBPAYLOAD_DIR="libpayload"
# Args:
#   $1: Target to build
#   $2: Build directory to use.
#   $3: Firmware file to use for LIBPAYLOAD_DIR
#   $4+: Any other Makefile arguments.
dc_make() {
	local target="$1"
	local builddir="$2"
	local libpayload

	[[ -n "$3" ]] && libpayload="LIBPAYLOAD_DIR=${SYSROOT}/firmware/$3/"

	shift 3
	emake VB_SOURCE="${VBOOT_REFERENCE_DESTDIR}" \
		PD_SYNC=$(usev pd_sync) \
		obj="${builddir}" \
		${libpayload} \
		"${target}" \
		"$@"
}

# Build depthcharge for the current board.
# Builds the various output files for depthcharge:
#   depthcharge.elf   - normal image
#   dev.elf           - developer image
#   netboot.elf       - network image
#   fastboot.elf      - fastboot image (ise 'fastboot' USE flag is set)
# In addition, .map files are produced for each, and a .config file which
# holds the configuration that was used.
# Args
#   $1: board to build for.
make_depthcharge() {
	local board="$1"
	local builddir="$2"

	if use mocktpm ; then
		echo "CONFIG_MOCK_TPM=y" >> "board/${board}/defconfig"
	fi
	if use fwconsole ; then
		echo "CONFIG_CLI=y" >> "board/${board}/defconfig"
		echo "CONFIG_SYS_PROMPT=\"${board}: \"" >> \
		  "board/${board}/defconfig"
	fi
	if use detachable_ui ; then
		echo "CONFIG_DETACHABLE_UI=y" >> "board/${board}/defconfig"
	fi

	[[ ${PV} == "9999" ]] && dc_make distclean "${builddir}" libpayload
	dc_make defconfig "${builddir}" libpayload BOARD="${board}"
	cp .config "${builddir}/depthcharge.config"

	dc_make depthcharge "${builddir}" libpayload
	dc_make dev "${builddir}" libpayload_gdb
	dc_make netboot "${builddir}" libpayload_gdb

	if use fastboot; then
		dc_make fastboot "${builddir}" libpayload
	fi
}

src_compile() {
	# Firmware related binaries are compiled with a 32-bit toolchain
	# on 64-bit platforms
	if use amd64 ; then
		export CROSS_COMPILE="i686-pc-linux-gnu-"
		export CC="${CROSS_COMPILE}gcc"
	else
		export CROSS_COMPILE=${CHOST}-
	fi

	if use unibuild; then
		local model

		for model in $(get_model_build_targets); do
			make_depthcharge "${model}" "${model}"
		done
	else
		make_depthcharge "$(get_board)" build
	fi
}

do_install() {
	local board="$1"
	local builddir="$2"
	local dstdir="/firmware"

	if [[ -n "${model}" ]]; then
		dstdir+="/${model}"
		einfo "Installing depthcharge ${model} into ${dest_dir}"
	fi
	insinto "${dstdir}"

	pushd "${builddir}" >/dev/null || \
		die "couldn't access ${builddir}/ directory"

	local files_to_copy=(
		depthcharge.config
		{netboot,depthcharge,dev}.elf{,.map}
	)

	if use fastboot ; then
		files_to_copy+=(fastboot.elf{,.map})
	fi

	insinto "${dstdir}/depthcharge"
	doins "${files_to_copy[@]}"

	popd >/dev/null
}

src_install() {
	local model

	if use unibuild; then
		for model in $(get_model_build_targets); do
			do_install "${model}" "${model}"
		done
	else
		do_install "$(get_board)" build
	fi
}
