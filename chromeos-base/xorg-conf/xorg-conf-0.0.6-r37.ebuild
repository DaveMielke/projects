# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# NOTE: This ebuild could be overridden in an overlay to provide a
# board-specific xorg.conf as necessary.

EAPI=4
CROS_WORKON_COMMIT="16ca96cf57190dd7b6115f14500280224c96125a"
CROS_WORKON_TREE="bd99e1963a1ed329423ace3e9708499b99f456eb"
CROS_WORKON_PROJECT="chromiumos/platform/xorg-conf"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-board cros-workon

DESCRIPTION="Board specific xorg configuration file."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="alex butterfly cmt -egl elan -exynos mario stout synaptics -tegra"

RDEPEND="!chromeos-base/touchpad-linearity"
DEPEND="x11-base/xorg-server"

src_install() {
	local board=$(get_current_board_no_variant)
	local board_variant=$(get_current_board_with_variant)

	insinto /etc/X11
	if ! use tegra; then
		doins xorg.conf
	fi

	insinto /etc/X11/xorg.conf.d
	if use tegra; then
		doins tegra.conf
	elif use exynos && use egl; then
		doins exynos.conf
	fi

	# Since syntp does not use evdev (/dev/input/event*) device nodes,
	# its .conf snippet can be installed alongside one of the
	# evdev-compatible xf86-input-* touchpad drivers.
	if use synaptics; then
		doins 50-touchpad-syntp.conf
	fi
	# Enable exactly one evdev-compatible X input touchpad driver.
	if use cmt; then
		doins 50-touchpad-cmt.conf
		if use elan; then
			doins 50-touchpad-cmt-elan.conf
		elif use alex; then
			doins 50-touchpad-cmt-alex.conf
		elif use butterfly; then
			doins 50-touchpad-cmt-butterfly.conf
		elif use stout; then
			doins 50-touchpad-cmt-stout.conf
		elif use mario; then
			doins 50-touchpad-cmt-mario.conf
		elif [[ "${board}" = "x86-zgb" || "${board}" = "x86-zgb32" ]]; then
			doins 50-touchpad-cmt-zgb.conf
		elif [ "${board_variant}" = "tegra2_aebl" ]; then
			doins 50-touchpad-cmt-aebl.conf
		elif [ "${board_variant}" = "tegra2_kaen" ]; then
			doins 50-touchpad-cmt-kaen.conf
		elif [[ "${board}" = "lumpy" || "${board}" = "lumpy64" ]]; then
			doins 50-touchpad-cmt-lumpy.conf
		elif [ "${board}" = "link" ]; then
			doins 50-touchpad-cmt-link.conf
		elif [ "${board}" = "daisy" ]; then
			doins 50-touchpad-cmt-daisy.conf
		elif [ "${board}" = "parrot" ]; then
			doins 50-touchpad-cmt-parrot.conf
		elif [ "${board}" = "falco" ]; then
			doins 50-touchpad-cmt-falco.conf
		elif [ "${board}" = "puppy" ]; then
			doins 50-touchpad-cmt-puppy.conf
		fi
	elif use mario; then
		doins 50-touchpad-synaptics-mario.conf
	else
		doins 50-touchpad-synaptics.conf
	fi
	doins 20-mouse.conf
	doins 20-touchscreen.conf

	insinto "/usr/share/gestures"
	case ${board} in
	lumpy|lumpy64)
		doins "files/lumpy_linearity.dat" ;;
	daisy)
		doins "files/daisy_linearity.dat" ;;
	esac
}
