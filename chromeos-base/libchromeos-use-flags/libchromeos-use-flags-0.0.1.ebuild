# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit cros-debug

DESCRIPTION="Text file listing USE flags for chromeos-base/libchromeos"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

# NB: Flags listed here are off by default unless prefixed with a '+'.
# This list is lengthy since it determines the USE flags that will be written to
# the /etc/ui_use_flags.txt file that's used to generate Chrome's command line.
IUSE="
	allow_consumer_kiosk
	arc
	arc_force_2x_scaling
	arc_oobe_optin
	arc_oobe_optin_no_skip
	arc_transition_m_to_n
	arcvm
	asan
	background_blur
	big_little
	biod
	caroline
	cheets
	cfm_enabled_device
	compupdates
	cros-debug
	disable_flash_hw_video_decode
	disable_low_latency_audio
	disable_webaudio
	drm_atomic
	edge_touch_filtering
	eve
	gpu_sandbox_allow_sysv_shm
	gpu_sandbox_failures_not_fatal
	gpu_sandbox_start_after_initialization
	gpu_sandbox_start_early
	has_diamond_key
	has_hdd
	highdpi
	instant_tethering
	internal_stylus
	kevin
	kvm_host
	legacy_keyboard
	legacy_power_button
	link
	low_pressure_touch_filtering
	ml_service
	moblab
	native_assistant
	native_gpu_memory_buffers
	natural_scroll_default
	neon
	nocturne
	oobe_skip_postlogin
	oobe_skip_to_login
	opengles
	ozone
	passive_event_listeners
	pita
	pointer_events
	rialto
	rialto_enterprise_enrollment
	screenshare_sw_codec
	stylus
	test
	touchscreen_wakeup
	touchview
	touch_centric_device
	veyron_mickey
	veyron_minnie
	voice_interaction
	+X
"

S=${WORKDIR}

src_install() {
	# Install a file containing a list of currently-set USE flags that
	# ChromiumCommandBuilder reads at runtime while constructing Chrome's
	# command line.
	local path="${WORKDIR}/ui_use_flags.txt"
	cat <<EOF >"${path}"
# This file is just for libchromeos's ChromiumCommandBuilder class.
# Don't use it for anything else. Your code will break.
EOF

	# If you need to use a new flag, add it to $IUSE at the top of the file.
	local flags=( ${IUSE} )
	local flag
	for flag in ${flags[@]/#[-+]} ; do
		usev ${flag}
	done | sort -u >>"${path}"

	insinto /etc
	doins "${path}"
}
