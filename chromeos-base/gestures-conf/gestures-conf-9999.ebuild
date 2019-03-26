# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_LOCALNAME="xorg-conf"
CROS_WORKON_PROJECT="chromiumos/platform/xorg-conf"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-board cros-workon user

DESCRIPTION="Board specific gestures library configuration file."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="~*"
IUSE="elan"

RDEPEND="!chromeos-base/touchpad-linearity
	!<=chromeos-base/xorg-conf-0.0.6-r128"
DEPEND=""

src_install() {
	local board=$(get_current_board_no_variant)
	local board_variant=$(get_current_board_with_variant)

	insinto /etc/gesture

	# -cheets, -arcnext, -campfire, and -kernelnext variants are running on
	# the same hardware as their non-cheets, non-arcnext, non-campfire, and
	# non-kernelnext counterpart. Strip the suffix to re-use the config.
	local suffix
	for suffix in cheets arcnext campfire kernelnext; do
		board_variant=${board_variant%-${suffix}}
		board=${board%-${suffix}}
	done

	# Enable exactly one evdev-compatible X input touchpad driver.
	#
	# Note: If possible, use the following xorg config names to allow
	# this ebuild to install them automatically:
	#    - 50-touchpad-cmt-$BOARD.conf
	#    - 60-touchpad-cmt-$BOARD_VARIANT.conf
	# e.g. daisy_skate will include the files:
	#    - 50-touchpad-cmt-daisy.conf
	#    - 60-touchpad-cmt-daisy_skate.conf
	doins 40-touchpad-cmt.conf
	if use elan; then
		doins 50-touchpad-cmt-elan.conf
	elif [[ "${board}" = "daisy" && "${board_variant}" = "${board}" ]]; then
		doins 50-touchpad-cmt-daisy.conf
		doins 50-touchpad-cmt-pit.conf # Some Lucas's use Pit Touchpad module
	elif [ "${board_variant}" = "daisy_spring" ]; then
		doins 50-touchpad-cmt-spring.conf
	elif [ "${board_variant}" = "peach_pit" ]; then
		doins 50-touchpad-cmt-pit.conf
	elif [ "${board_variant}" = "peach_pi" ]; then
		doins 50-touchpad-cmt-pi.conf
	else
		if [ -f "50-touchpad-cmt-${board}.conf" ]; then
			doins "50-touchpad-cmt-${board}.conf"
		fi
		if [ -f "60-touchpad-cmt-${board_variant}.conf" ]; then
			doins "60-touchpad-cmt-${board_variant}.conf"
		fi
	fi
	doins 20-mouse.conf

	insinto "/usr/share/gestures"
	case ${board} in
	daisy)
		doins "files/daisy_linearity.dat" ;;
	esac
}

