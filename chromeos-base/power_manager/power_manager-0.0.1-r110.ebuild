# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="06c569f683119921f69b2f20f554112612a6b0fe"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Power Manager for Chromium OS"
HOMEPAGE="http://src.chromium.org"
LICENSE="BSD"
SLOT="0"
IUSE="-new_power_button test -lockvt -touchui"
KEYWORDS="amd64 arm x86"

RDEPEND="chromeos-base/libcros
	chromeos-base/metrics
	dev-cpp/gflags
	dev-cpp/glog
	x11-base/xorg-server
	x11-libs/gtk+
	x11-libs/libX11
	x11-libs/libXext"

DEPEND="${RDEPEND}
	chromeos-base/libchrome
	chromeos-base/libchromeos
	test? ( dev-cpp/gmock )
	test? ( dev-cpp/gtest )
	test? ( x11-libs/libXtst )
	x11-proto/xextproto"

src_compile() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG

	local power_button
	local suspend_lockvt
	if use new_power_button; then
		power_button=NEW
	else
		power_button=LEGACY
	fi
	if use lockvt; then
		suspend_lockvt=1
	else
		suspend_lockvt=0
	fi
	# TODO(davidjames): parallel builds
	scons POWER_BUTTON="$power_button" lockvt=$suspend_lockvt || \
		die "power_manager compile failed."
}

src_test() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG

	# Build tests
	scons tests || die "tests compile failed."

	# Run tests if we're on x86
	if ! use x86 ; then
		echo Skipping tests on non-x86 platform...
	else
		export DISPLAY=:1
		trap 'kill %1 && wait' exit
		"${SYSROOT}/usr/bin/Xvfb" ${DISPLAY} 2>/dev/null &
		sleep 2
		for ut in file_tagger powerd; do
			"${S}/${ut}_unittest" \
				${GTEST_ARGS} || die "${ut}_unittest failed"
		done
		kill %1 && wait
		trap - exit
		for ut in idle_dimmer plug_dimmer; do
			"${S}/${ut}_unittest" \
				${GTEST_ARGS} || die "${ut}_unittest failed"
		done
	fi
}

src_install() {
	dobin "${S}/backlight-tool"
	dobin "${S}/powerd"
	dobin "${S}/powerm"
	dobin "${S}/powerd_lock_screen"
	dobin "${S}/powerd_suspend"
	dobin "${S}/send_metrics_on_resume"
	dobin "${S}/suspend_delay_sample"
	dobin "${S}/xidle-example"
	insinto "/usr/share/power_manager"
	for item in ${S}/config/*; do
		doins ${item}
	done
	insinto "/etc/dbus-1/system.d"
	doins "${S}/org.chromium.PowerManager.conf"

	# Install scripts for setting up light sensor
	exeinto "/lib/udev"
	doexe "${S}/light-sensor-set-multiplier.sh"

	# The platform specific light sensor tuning value is specified
	# in the overlay's make.conf.
	if [ -n "$LIGHT_SENSOR_TUNEVAL" ]; then
	sed -i -e "/TUNEVAL=/s/=.*/=$LIGHT_SENSOR_TUNEVAL/" \
		"${D}/lib/udev/light-sensor-set-multiplier.sh"
	fi

	# Safely change this name by supporting backward compatibility.
	if [ -f "${S}/tsl2563-install.sh" ]; then
		doexe "${S}/tsl2563-install.sh"
	else
		doexe "${S}/light-sensor-install.sh"

		# And of course the new file supports overlay-specific values.
		sed -i -e "/NAME=/s/=.*/=${LIGHT_SENSOR_NAME:-tsl2563}/" \
			-e "/BUS=/s/=.*/=${LIGHT_SENSOR_BUS:-2}/" \
			-e "/ADDRESS=/s/=.*/=${LIGHT_SENSOR_ADDRESS:-0x29}/" \
			"${D}/lib/udev/light-sensor-install.sh"
	fi

	# Install light sensor udev rules
	insinto "/etc/udev/rules.d"
	doins "${S}/99-light-sensor.rules"

	if use touchui; then
		if [ ! -e "${D}/usr/share/power_manager/use_lid" ]; then
			die "use_lid config file missing"
		fi
		echo "0" > "${D}/usr/share/power_manager/use_lid"
	fi
}
