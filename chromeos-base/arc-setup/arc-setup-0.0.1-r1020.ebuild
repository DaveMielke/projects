# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="a1b04d1c66336fe6468130ea11ee8f000f1c8d02"
CROS_WORKON_TREE=("638bfde957a502ad58d182712c1ebdf335f9a3da" "2050e6d5d2193b95f3ac16c5999f5d4e0e57677a" "ec73a00693eb4b63b8b5d70cc49af62e6329aa3f" "9fc84a9209cf9d428d562666ba4c122c02b9cd14" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk arc/setup chromeos-config metrics .gn"

PLATFORM_NATIVE_TEST="yes"
PLATFORM_SUBDIR="arc/setup"

inherit cros-workon platform

DESCRIPTION="Set up environment to run ARC."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/arc/setup"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="
	arcpp
	arcvm
	esdfs
	fuzzer
	generated_cros_config
	houdini
	houdini64
	ndk_translation
	unibuild"

REQUIRED_USE="|| ( arcpp arcvm )"

COMMON_DEPEND="
	esdfs? ( chromeos-base/arc-sdcard )
	chromeos-base/bootstat:=
	chromeos-base/chromeos-config-tools:=
	chromeos-base/cryptohome-client:=
	chromeos-base/metrics:=
	dev-libs/dbus-glib:=
	dev-libs/protobuf:=
	sys-libs/libselinux:=
	chromeos-base/minijail:=
"

RDEPEND="${COMMON_DEPEND}
	chromeos-base/patchpanel
	arcvm? ( chromeos-base/crosvm )
	arcpp? (
		chromeos-base/swap-init
		esdfs? ( sys-apps/restorecon )
	)
"

DEPEND="${COMMON_DEPEND}
	unibuild? (
		!generated_cros_config? ( chromeos-base/chromeos-config )
		generated_cros_config? ( chromeos-base/chromeos-config-bsp:= )
	)
	chromeos-base/system_api:=[fuzzer?]
"


enable_esdfs() {
	[[ -f "$1" ]] || die
	local data=$(jq ".USE_ESDFS=true" "$1")
	echo "${data}" > "$1" || die
}


src_install() {
	# Used for both ARCVM and ARC.
	dosbin "${OUT}"/arc-remove-data
	dosbin "${OUT}"/arc-remove-stale-data

	# Some binaries are only for ARCVM
	if use arcvm; then
		dosbin "${OUT}"/arc-apply-per-board-config
		dosbin "${OUT}"/arc-create-data
		insinto /etc/init
		doins etc/arc-create-data.conf
	fi

	# Other files are only for ARC.
	if use arcpp; then
		dosbin "${OUT}"/arc-setup
		insinto /etc/init
		doins etc/arc-boot-continue.conf
		doins etc/arc-kmsg-logger.conf
		doins etc/arc-lifetime.conf
		doins etc/arc-sensor.conf
		doins etc/arc-update-restorecon-last.conf
		if use esdfs; then
			doins etc/arc-sdcard.conf
			doins etc/arc-sdcard-mount.conf
		fi
		doins etc/arc-sysctl.conf
		doins etc/arc-system-mount.conf
		doins etc/arc-ureadahead.conf

		insinto /usr/share/arc-setup
		doins etc/config.json

		if use esdfs; then
			enable_esdfs "${D}/usr/share/arc-setup/config.json"
		fi

		insinto /opt/google/containers/arc-art
		doins "${OUT}/dev-rootfs.squashfs"

		# container-root is where the root filesystem of the container in which
		# patchoat and dex2oat runs is mounted. dev-rootfs is mount point
		# for squashfs.
		diropts --mode=0700 --owner=root --group=root
		keepdir /opt/google/containers/arc-art/mountpoints/container-root
		keepdir /opt/google/containers/arc-art/mountpoints/dev-rootfs
		keepdir /opt/google/containers/arc-art/mountpoints/vendor

		platform_fuzzer_install "${S}"/OWNERS "${OUT}"/arc_setup_util_find_all_properties_fuzzer
		platform_fuzzer_install "${S}"/OWNERS "${OUT}"/arc_setup_util_find_fingerprint_and_sdk_version_fuzzer
	fi

	insinto /etc/dbus-1/system.d
	doins etc/dbus-1/ArcUpstart.conf
}

platform_pkg_test() {
	platform_test "run" "${OUT}/arc-setup_testrunner"
}