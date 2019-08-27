# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT=("7e37510d4ab80ca5c18937bcb9b99a39c0b372e5" "a2c8b92227ddf33fd934357d0aea39bbe36e6293")
CROS_WORKON_TREE=("b050a2ab2836dd6da5e48eab3fd4ac328d4325bc" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb" "08c55997efd9ffb442f748f0ff72798fa79168be")
CROS_WORKON_LOCALNAME=("platform2" "aosp/system/update_engine")
CROS_WORKON_PROJECT=("chromiumos/platform2" "aosp/platform/system/update_engine")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/platform2/update_engine")
CROS_WORKON_USE_VCSID=1
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_SUBTREE=("common-mk .gn" "")

PLATFORM_SUBDIR="update_engine"
# Some unittests crash when run through qemu/arm.  Should figure this out.
PLATFORM_NATIVE_TEST="yes"

inherit toolchain-funcs cros-debug cros-workon platform systemd

DESCRIPTION="Chrome OS Update Engine"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="cros_p2p +dbus dlc -hwid_override +power_management systemd"

COMMON_DEPEND="
	app-arch/bzip2
	!chromeos-base/brillo_update_payload
	chromeos-base/chromeos-ca-certificates
	!<chromeos-base/cros-devutils-0.0.3
	chromeos-base/libbrillo
	chromeos-base/metrics
	chromeos-base/vboot_reference
	cros_p2p? ( chromeos-base/p2p )
	dev-libs/expat
	dev-libs/openssl:=
	dev-libs/protobuf:=
	dev-libs/xz-embedded
	dev-util/bsdiff
	dev-util/puffin
	net-misc/curl
	sys-apps/rootdev"

DEPEND="
	app-arch/xz-utils
	chromeos-base/debugd-client
	dlc? ( chromeos-base/dlcservice-client )
	chromeos-base/power_manager-client
	chromeos-base/session_manager-client
	chromeos-base/shill-client
	chromeos-base/system_api:=
	chromeos-base/update_engine-client
	sys-fs/e2fsprogs
	test? ( sys-fs/squashfs-tools )
	${COMMON_DEPEND}"

DELTA_GENERATOR_RDEPEND="
	app-arch/unzip
	app-arch/xz-utils
	app-shells/bash
	brillo-base/libsparse
	dev-util/shflags
	sys-fs/e2fsprogs
	sys-fs/squashfs-tools
"

RDEPEND="
	chromeos-base/chromeos-installer
	${COMMON_DEPEND}
	cros_host? ( ${DELTA_GENERATOR_RDEPEND} )
	power_management? ( chromeos-base/power_manager )
	virtual/update-policy
"

platform_pkg_test() {
	local unittests_binary="${OUT}"/update_engine_unittests

	# The unittests will try to exec `./helpers`, so make sure we're in
	# the right dir to execute things.
	cd "${OUT}"
	# The tests also want keys to be in the current dir.
	# .pub.pem files are generated on the "gen" directory.
	for f in unittest_key.pub.pem unittest_key2.pub.pem; do
		cp "${S}"/${f/.pub} ./ || die
		ln -fs gen/include/update_engine/$f $f  \
			|| die "Error creating the symlink for $f."
	done

	# The unit tests check to make sure the minor version value in
	# update_engine.conf match the constants in update engine, so we need to be
	# able to access this file.
	cp "${S}/update_engine.conf" ./

	# If GTEST_FILTER isn't provided, we run two subsets of tests
	# separately: the set of non-privileged  tests (run normally)
	# followed by the set of privileged tests (run as root).
	# Otherwise, we pass the GTEST_FILTER environment variable as
	# an argument and run all the tests as root; while this might
	# lead to tests running with excess privileges, it is necessary
	# in order to be able to run every test, including those that
	# need to be run with root privileges.
	if [[ -z "${GTEST_FILTER}" ]]; then
		platform_test "run" "${unittests_binary}" 0 '-*.RunAsRoot*'
		platform_test "run" "${unittests_binary}" 1 '*.RunAsRoot*'
	else
		platform_test "run" "${unittests_binary}" 1 "${GTEST_FILTER}"
	fi
}

src_install() {
	dosbin "${OUT}"/update_engine
	dobin "${OUT}"/update_engine_client

	if use cros_host; then
		dobin "${S}"/scripts/brillo_update_payload
		dobin "${OUT}"/delta_generator
	fi

	insinto /etc
	doins update_engine.conf

	if use systemd; then
		systemd_dounit "${FILESDIR}"/update-engine.service
		systemd_enable_service multi-user.target update-engine.service
	else
		# Install upstart script
		insinto /etc/init
		doins init/update-engine.conf
	fi

	# Install DBus configuration
	insinto /etc/dbus-1/system.d
	doins UpdateEngine.conf

	platform_fuzzer_install "${S}"/OWNERS "${OUT}"/update_engine_omaha_request_action_fuzzer \
		--dict "${S}"/fuzz/xml.dict
}
