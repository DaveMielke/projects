# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_PROJECT=(
	"chromiumos/third_party/coreboot"
	"chromiumos/platform/vboot_reference"
	"chromiumos/third_party/coreboot/blobs"
)
CROS_WORKON_LOCALNAME=(
	"coreboot"
	"../platform/vboot_reference"
	"coreboot/3rdparty"
)
CROS_WORKON_DESTDIR=(
	"${S}"
	"${S}/vboot_reference"
	"${S}/3rdparty"
)

inherit cros-board cros-workon toolchain-funcs

DESCRIPTION="coreboot firmware"
HOMEPAGE="http://www.coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~*"
IUSE="em100-mode memmaps quiet-cb rmt vmx"

PER_BOARD_BOARDS=(
	bayleybay beltino bolt butterfly falco fox link lumpy panther parrot
	peppy rambi samus slippy stout stout32 stumpy variant-peach-pit
	daisy gizmo nyan
)

DEPEND_BLOCKERS="${PER_BOARD_BOARDS[@]/#/!sys-boot/chromeos-coreboot-}"

RDEPEND="
	chromeos-base/vboot_reference
	${DEPEND_BLOCKERS}
	!virtual/chromeos-coreboot
	virtual/coreboot-private-files
	"

# Dependency shared by x86 and amd64.
DEPEND_X86="
	sys-power/iasl
	sys-boot/chromeos-mrc
	sys-apps/coreboot-utils
	"

DEPEND_ARM="
	sys-apps/coreboot-utils
	"

DEPEND_ARM64="
	sys-apps/coreboot-utils
	"

DEPEND="
	${DEPEND_BLOCKERS}
	x86? ($DEPEND_X86)
	amd64? ($DEPEND_X86)
	arm? ($DEPEND_ARM)
	arm64? ($DEPEND_ARM64)
	"

src_prepare() {
	local privdir="${SYSROOT}/firmware/coreboot-private"
	local file
	while read -d $'\0' -r file; do
		rsync --recursive --links --executability --ignore-existing \
		      "${file}" ./ || die
	done < <(find "${privdir}" -maxdepth 1 -mindepth 1 -print0)

	local board=$(get_current_board_with_variant)
	if [[ ! -s "configs/config.${board}" ]]; then
		board=$(get_current_board_no_variant)
	fi

	if [[ -s "configs/config.${board}" ]]; then
		cp -v "configs/config.${board}" .config
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

	cp .config .config_serial
	cat "configs/fwserial.${board}" >> .config_serial || die
}

make_coreboot() {
	local builddir="$1"

	yes "" | emake oldconfig
	emake obj="${builddir}"

	# Modify firmware descriptor if building for the EM100 emulator.
	if use em100-mode; then
		ifdtool --em100 "${builddir}/coreboot.rom" || die
		mv "${builddir}/coreboot.rom"{.new,} || die
	fi

	# Extract the coreboot ramstage file into the build dir.
	cbfstool "${builddir}/coreboot.rom" extract \
		-n "fallback/ramstage" \
		-f "${builddir}/ramstage.stage" || die

	# Extract the reference code stage into the build dir if present.
	cbfstool "${builddir}/coreboot.rom" extract \
		-n "fallback/refcode" \
		-f "${builddir}/refcode.stage" || true
}

src_compile() {
	tc-export CC

	# Set KERNELREVISION (really coreboot revision) to the ebuild revision
	# number followed by a dot and the first seven characters of the git
	# hash. The name is confusing but consistent with the coreboot
	# Makefile.
	local sha1v="${VCSID/*-/}"
	export KERNELREVISION=".${PV}.${sha1v:0:7}"

	# Firmware related binaries are compiled with a 32-bit toolchain
	# on 64-bit platforms
	if use amd64 ; then
		export CROSS_COMPILE="i686-pc-linux-gnu-"
		export CC="${CROSS_COMPILE}gcc"
	else
		export CROSS_COMPILE=${CHOST}-
	fi

	elog "Toolchain:\n$(sh util/xcompile/xcompile)\n"

	make_coreboot "build"

	# Build a second ROM with serial support for developers
	mv .config_serial .config
	make_coreboot "build_serial"

	# Build cbmem for the target
	cd util/cbmem
	emake clean
	CROSS_COMPILE="${CHOST}-" emake
}

src_install() {
	local mapfile
	local board=$(get_current_board_with_variant)
	if [[ ! -s "configs/config.${board}" ]]; then
		board=$(get_current_board_no_variant)
	fi

	dobin util/cbmem/cbmem
	insinto /firmware
	newins "build/coreboot.rom" coreboot.rom
	newins "build_serial/coreboot.rom" coreboot.rom.serial
	newins "build/ramstage.stage" ramstage.stage
	newins "build_serial/ramstage.stage" ramstage.stage.serial
	if [[ -f "build/refcode.stage" ]]; then
		newins "build/refcode.stage" refcode.stage
		newins "build_serial/refcode.stage" refcode.stage.serial
	fi
	OPROM=$( awk 'BEGIN{FS="\""} /CONFIG_VGA_BIOS_FILE=/ { print $2 }' \
		configs/config.${board} )
	CBFSOPROM=pci$( awk 'BEGIN{FS="\""} /CONFIG_VGA_BIOS_ID=/ { print $2 }' \
		configs/config.${board} ).rom
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
