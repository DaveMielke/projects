# Copyright 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# A note about this ebuild: this ebuild is Unified Build enabled but
# not in the way in which most other ebuilds with Unified Build
# knowledge are: the primary use for this ebuild is for engineer-local
# work or firmware builder work. In both cases, the build might be
# happening on a branch in which only one of many of the models are
# available to build. The logic in this ebuild succeeds so long as one
# of the many models successfully builds.

EAPI=5
CROS_WORKON_COMMIT="0554955a51b0e7e4eff63f475b51d8e3aabc9c26"
CROS_WORKON_TREE="1841e514bd920fea9331ed8461fe13232b2ace3d"
CROS_WORKON_PROJECT="chromiumos/platform/ec"
CROS_WORKON_LOCALNAME="ec"

inherit cros-workon cros-ec-board user

DESCRIPTION="Chrome OS EC Utility"

HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-cr50_onboard -cr50_utils static unibuild -updater_utils"
IUSE="${IUSE} cros_host +cros_ec_utils"

DEPEND="dev-embedded/libftdi:=
	virtual/libusb:1="
RDEPEND="${DEPEND}"

pkg_preinst() {
	enewgroup "dialout"
}

src_configure() {
	cros-workon_src_configure
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

	# Do not set BOARD yet, as gsctool is built for cr50.
	if use cr50_onboard || use cr50_utils || use cros_host; then
		# Get rid of the local compilation products in case they are
		# present.
		emake -C extra/usb_updater clean

		# Make sure to override environment setting for BOARD, if any.
		BOARD=cr50 emake -C extra/usb_updater gsctool
	fi

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

	if use cr50_onboard || use cr50_utils || use cros_host; then
		dosbin "extra/usb_updater/gsctool"
		dosbin "util/chargen"
		dosym "gsctool" "/usr/sbin/usb_updater"
	fi

	if [[ -d "board/${BOARD}/userspace/etc/init" ]] ; then
		insinto /etc/init
		doins board/${BOARD}/userspace/etc/init/*.conf
	fi
	if [[ -d "board/${BOARD}/userspace/usr/share/ec" ]] ; then
		insinto /usr/share/ec
		doins board/${BOARD}/userspace/usr/share/ec/*
	fi
}

pkg_postinst() {
	if ! $(id -Gn "$(logname)" | grep -qw "dialout") ; then
		usermod -a -G "dialout" "$(logname)"
		einfo "A new group, dialout is added." \
			"Please re-login to apply this change."
	fi
}
