# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="89844538a356effd043c81394f8e0b2bc80b8d65"
CROS_WORKON_TREE=("1d995a5f11b89f06713e6b213ea3f8741ace4008" "bad653e3eaaf33e63f8506513d637f0c23731e6b" "daa242fb068b5747969b1f0976b8ece03041cc8e" "36f83bcb831a0ae79c608f2aedf5846f9d8a3018")
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk arc/setup chromeos-config metrics"

PLATFORM_NATIVE_TEST="yes"
PLATFORM_SUBDIR="arc/setup"
PLATFORM_GYP_FILE="arc-setup.gyp"

inherit cros-board cros-workon platform

DESCRIPTION="Set up environment to run ARC."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/arc/setup"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="
	android-container-nyc
	houdini
	ndk_translation
	unibuild"

RDEPEND="
	!<chromeos-base/chromeos-cheets-scripts-0.0.4
	unibuild? ( chromeos-base/chromeos-config )
	chromeos-base/chromeos-config-tools
	chromeos-base/cryptohome-client
	chromeos-base/libbrillo
	chromeos-base/metrics
	chromeos-base/minijail
	chromeos-base/swap-init
	sys-libs/libselinux
	dev-libs/dbus-glib
	dev-libs/protobuf"

DEPEND="${RDEPEND}
	chromeos-base/system_api"


set_density_scale() {
	local density=160
	# Scale is passed in percent
	local scale=100
	case $(get_current_board_with_variant) in
		betty*|caroline*|chell|eve*|kevin*|newbie|novato*|samus*|scarlet*|soraka*) # 2x HiDPI
			density=240
			scale=200 ;;
		nautilus*) # 1.6x. Among the standard Android dpi, the closest value 213 is chosen.
			density=213
			scale=160 ;;
		grunt*) # 1x.  Set here to avoid being picked up by gru* below.
			density=160
			scale=100 ;;
		cave*|elm*|gru*) # 1.25x default scaling
			density=160
			scale=125 ;;
		cyan*|kahlee*|veyron_minnie*) # 1x
			density=160
			scale=100 ;;
		*)
			ewarn "Unknown board - using default pixel density of -1" ;;
	esac
	grep -e "ARC_LCD_DENSITY=-1" "$1" || die "set_density_scale failed! Density pattern not found."
	sed -i "s/\(ARC_LCD_DENSITY=\)-1/\1${density}/" "$1" || die "set_density_scale failed!"
	grep -e "ARC_UI_SCALE=-1" "$1" || die "set_density_scale failed! Scale pattern not found."
	sed -i "s/\(ARC_UI_SCALE=\)-1/\1${scale}/" "$1" || die "set_density_scale failed!"
}

# Enables the option to clear app/*/oat/ after update.
enable_clear_app_executables_after_ota() {
	local arc_setup_conf="$1"
	grep -e "^export DELETE_DATA_EXECUTABLES_AFTER_OTA=0" "${arc_setup_conf}" && \
		sed -i "s/^\(export DELETE_DATA_EXECUTABLES_AFTER_OTA=\)0/\11/" "${arc_setup_conf}" || \
		die "enable_clear_app_executables_after_ota failed!"
}

src_install() {
	dosbin "${OUT}"/arc-setup
	dosbin arc_setup_wrapper.sh

	insinto /etc/init
	doins etc/arc-boot-continue.conf
	doins etc/arc-kmsg-logger.conf
	doins etc/arc-lifetime.conf
	doins etc/arc-sensor.conf
	doins etc/arc-start-sysctl.conf
	doins etc/arc-stop-sysctl.conf
	doins etc/arc-system-mount.conf
	doins etc/arc-ureadahead.conf
	doins etc/arc-ureadahead-trace.conf

	# TODO(hidehiko): Move arc-setup-env from /etc/init to /etc.
	doins etc/arc-setup-env
	set_density_scale "${D}/etc/init/arc-setup-env"
	enable_clear_app_executables_after_ota "${D}/etc/init/arc-setup-env"

	insinto /opt/google/containers/arc-art
	doins "${OUT}/dev-rootfs.squashfs"

	# container-root is where the root filesystem of the container in which
	# patchoat and dex2oat runs is mounted. dev-rootfs is mount point
	# for squashfs.
	diropts --mode=0700 --owner=root --group=root
	keepdir /opt/google/containers/arc-art/mountpoints/container-root
	keepdir /opt/google/containers/arc-art/mountpoints/dev-rootfs
	keepdir /opt/google/containers/arc-art/mountpoints/vendor
}

platform_pkg_test() {
	platform_test "run" "${OUT}/arc-setup_testrunner"
}
