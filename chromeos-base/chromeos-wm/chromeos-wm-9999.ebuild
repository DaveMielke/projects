# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit cros-debug cros-workon flag-o-matic toolchain-funcs

DESCRIPTION="Chrome OS window manager"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="opengles -touchui"

RDEPEND="chromeos-base/metrics
	chromeos-base/vboot_reference
	dev-cpp/gflags
	dev-cpp/glog
	dev-libs/libpcre
	dev-libs/protobuf
	media-libs/libpng
	net-misc/iputils
	net-wireless/iw
	sys-apps/dbus
	sys-apps/net-tools
	x11-libs/cairo
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libxcb
	!opengles? ( virtual/opengl )
	opengles? ( virtual/opengles )"
DEPEND="chromeos-base/libchrome
	chromeos-base/libchromeos
	chromeos-base/libcros
	dev-libs/vectormath
	${RDEPEND}"

# Print the number of jobs from $MAKEOPTS.
print_num_jobs() {
	local JOBS=$(echo $MAKEOPTS | sed -nre 's/.*-j\s*([0-9]+).*/\1/p')
	echo ${JOBS:-1}
}

CROS_WORKON_LOCALNAME="window_manager"
CROS_WORKON_PROJECT="window_manager"

src_compile() {
	tc-export CC CXX AR RANLIB LD NM
	cros-debug-add-NDEBUG
	use touchui && append-flags -DTOUCH_UI
	export CCFLAGS="$CFLAGS"

	local backend
	if use opengles ; then
		backend=OPENGLES
	else
		backend=OPENGL
	fi

	scons BACKEND="$backend" -j$(print_num_jobs) wm screenshot || \
		die "window_manager compile failed"
}

src_test() {
	scons -j$(print_num_jobs) tests || die "failed to build tests"

	if ! use x86 ; then
		echo Skipping tests on non-x86 platform...
	else
		for test in $(find -name '*_test' | sort); do
			"$test" ${GTEST_ARGS} || die "$test failed"
		done
	fi
}

src_install() {
	newbin wm chromeos-wm
	dobin screenshot
	dobin bin/cros-term
	dobin bin/crosh
	dobin bin/crosh-dev
	dobin bin/crosh-usb
	dobin bin/inputrc.crosh
	dobin bin/network_diagnostics

	into /
	dosbin bin/window-manager-session.sh
}
