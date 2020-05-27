# Copyright 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# A note about this ebuild: this ebuild is Unified Build enabled but
# not in the way in which most other ebuilds with Unified Build
# knowledge are: the primary use for this ebuild is for engineer-local
# work or firmware builder work. In both cases, the build might be
# happening on a branch in which only one of many of the models are
# available to build. The logic in this ebuild succeeds so long as one
# of the many models successfully builds.

EAPI=7
CROS_WORKON_COMMIT="85d87528a69a65f2c4b50ccd3e8357db14453020"
CROS_WORKON_TREE="e6cb6ca0ee6bf79c7bb8c5c463fed07a11618213"
CROS_WORKON_PROJECT="chromiumos/platform/ec"
CROS_WORKON_LOCALNAME="platform/ec"

inherit cros-workon cros-ec-board user

DESCRIPTION="Chrome OS EC Utility"

HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/ec/"
SRC_URI=""

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="static unibuild -updater_utils"
IUSE="${IUSE} cros_host +cros_ec_utils"

COMMON_DEPEND="dev-embedded/libftdi:=
	dev-libs/openssl:0=
	virtual/libusb:1="
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"

pkg_preinst() {
	enewgroup "dialout"
}

src_compile_cros_ec_utils() {
	get_ec_boards
	local board
	local some_board_built=false

	for board in "${EC_BOARDS[@]}"; do
		# We need to test whether the board make target
		# exists. For Unified Build EC_BOARDS, the engineer or
		# the firmware builder might be checked out on a
		# firmware branch where only one of the many models in
		# a family are actually available to build at the
		# moment. make fails with exit code 2 when the target
		# doesn't resolve due to error. For non-unibuilds, all
		# EC_BOARDS targets should exist and build.
		BOARD=${board} make -q clean

		if [[ $? -ne 2 ]]; then
			some_board_built=true
			BOARD=${board} emake utils-host

			# We only need one board for ec-utils
			break
		fi
	done

	if [[ ${some_board_built} == false ]]; then
		die "We were not able to find a board target to build from the \
set '${EC_BOARDS[*]}'"
	fi
}

src_compile() {
	tc-export AR CC PKG_CONFIG RANLIB
	# In platform/ec Makefile, it uses "CC" to specify target chipset and
	# "HOSTCC" to compile the utility program because it assumes developers
	# want to run the utility from same host (build machine).
	# In this ebuild file, we only build utility
	# and we may want to build it so it can
	# be executed on target devices (i.e., arm/x86/amd64), not the build
	# host (BUILDCC, amd64). So we need to override HOSTCC by target "CC".
	export HOSTCC="${CC} $(usex static '-static' '')"

	# Build Chromium EC utilities.
	use cros_ec_utils && src_compile_cros_ec_utils
}

src_install_cros_ec_utils() {
	get_ec_boards
	local board
	local some_board_installed=false

	for board in "${EC_BOARDS[@]}"; do
		if [[ -d "${S}/build/${board}" ]]; then
			some_board_installed=true
			if use cros_host; then
				dobin "build/${board}/util/cbi-util"
			else
				dosbin "build/$board/util/ectool"
				dosbin "build/$board/util/ec_sb_firmware_update"
			fi
			break
		fi
	done

	if [[ ${some_board_installed} == false ]]; then
		die "We were not able to install at least one board from the \
set '${EC_BOARDS[*]}'"
	fi
}

src_install() {
	# Install Chromium EC utilities.
	use cros_ec_utils && src_install_cros_ec_utils
}

pkg_postinst() {
	if ! $(id -Gn "$(logname)" | grep -qw "dialout") ; then
		usermod -a -G "dialout" "$(logname)"
		einfo "A new group, dialout is added." \
			"Please re-login to apply this change."
	fi
}
