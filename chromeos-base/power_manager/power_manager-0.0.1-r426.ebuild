# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="a7f365609a30b9d0e31ccd451916c76b1fa0fbea"
CROS_WORKON_TREE="64f158a80a4d8ec4ed40f5e0a69684c0851af8fa"

EAPI=4
CROS_WORKON_PROJECT="chromiumos/platform/power_manager"
CROS_WORKON_USE_VCSID="1"

inherit cros-debug cros-workon eutils toolchain-funcs

DESCRIPTION="Power Manager for Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="-new_power_button test -lockvt -nocrit -is_desktop -als -aura"
IUSE="${IUSE} -has_keyboard_backlight"

LIBCHROME_VERS="125070"

RDEPEND="app-misc/ddccontrol
	chromeos-base/metrics
	dev-cpp/gflags
	dev-cpp/glog
	dev-libs/glib
	sys-fs/udev"

DEPEND="${RDEPEND}
	chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	chromeos-base/libchromeos
	chromeos-base/system_api
	test? ( dev-cpp/gmock )
	test? ( dev-cpp/gtest )"

src_compile() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	export BASE_VER=${LIBCHROME_VERS}

	export USE_NEW_POWER_BUTTON=$(usex new_power_button y "")
	export USE_LOCKVT=$(usex lockvt y "")
	export USE_IS_DESKTOP=$(usex is_desktop y "")
	export USE_ALS=$(usex als y "")
	export USE_AURA=$(usex aura y "")
	export USE_HAS_KEYBOARD_BACKLIGHT=$(usex has_keyboard_backlight y "")

	emake
}

src_test() {
	# Run tests if we're on x86
	if use arm ; then
		echo Skipping tests on non-x86 platform...
	else
		emake tests
	fi
}

src_install() {
	# Built binaries
	dobin out/backlight-tool
	dobin out/backlight_dbus_tool
	dobin out/power_state_tool
	dobin out/power-supply-info
	dobin out/powerd
	dobin out/powerm
	dobin out/suspend_delay_sample

	# Scripts
	dobin debug_sleep_quickly
	dobin powerd_lock_screen
	dobin powerd_suspend
	dobin send_metrics_on_resume

	insinto /usr/share/power_manager
	doins config/*
	# If is a desktop system, shorten the react_ms, and bring in the
	# lock_ms to off_ms + react_ms
	if use is_desktop; then
		react="usr/share/power_manager/react_ms"
		plugged_off="usr/share/power_manager/plugged_off_ms"
		lock="usr/share/power_manager/lock_ms"
		echo "10000" > "${D}/${react}"
		plugged_off_ms=$(cat "${D}/${plugged_off}")
		echo "$(($plugged_off_ms + 10000))" > "${D}/${lock}"
	fi

	insinto /etc/dbus-1/system.d
	doins org.chromium.PowerManager.conf

	# Install udev rule to set usb hid devices to wake the system.
	exeinto /lib/udev
	doexe usb-hid-wake.sh

	insinto /lib/udev/rules.d
	doins 99-usb-hid-wake.rules

	# Nocrit disables low battery suspend percent by setting it to 0
	if use nocrit; then
		crit="usr/share/power_manager/low_battery_suspend_percent"
		if [ ! -e "${D}/${crit}" ]; then
			die "low_battery_suspend_percent config file missing"
		fi
		echo "0" > "${D}/${crit}"
	fi

	dodir /etc/dbus-1/system.d
	insinto /etc/dbus-1/system.d
	doins RootPowerManager.conf
}
