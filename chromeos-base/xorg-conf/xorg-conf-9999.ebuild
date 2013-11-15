# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# NOTE: This ebuild could be overridden in an overlay to provide a
# board-specific xorg.conf as necessary.

EAPI=4
CROS_WORKON_PROJECT="chromiumos/platform/xorg-conf"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-board cros-workon

DESCRIPTION="Board specific xorg configuration file."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="alex butterfly -egl elan -exynos mario stout -tegra"

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

	# Enable exactly one evdev-compatible X input touchpad driver.
	doins 40-touchpad-cmt.conf
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
	elif [[ "${board}" = "daisy" && "${board_variant}" = "${board}" ]]; then
		doins 50-touchpad-cmt-daisy.conf
	elif [ "${board_variant}" = "daisy_spring" ]; then
		doins 50-touchpad-cmt-spring.conf
	elif [ "${board}" = "parrot" ]; then
		doins 50-touchpad-cmt-parrot.conf
	elif [ "${board_variant}" = "peach_pit" ]; then
		doins 50-touchpad-cmt-pit.conf
	elif [ "${board}" = "peppy" ]; then
		doins 50-touchpad-cmt-peppy.conf
	elif [ "${board}" = "falco" ]; then
		doins 50-touchpad-cmt-falco.conf
	elif [ "${board}" = "puppy" ]; then
		doins 50-touchpad-cmt-puppy.conf
	elif [ "${board}" = "wolf" ]; then
		doins 50-touchpad-cmt-wolf.conf
	elif [ -f "50-touchpad-cmt-${board}.conf" ]; then
		doins "50-touchpad-cmt-${board}.conf"
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
