# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# Don't use Makefile.external here as it fetches from the network.
EAPI="5"

CROS_WORKON_COMMIT="aa896519b14416d2b3e842e18f6c070eb8b79a0b"
CROS_WORKON_TREE="6d0a1403799ea9191481152a885383fce1fe4713"
CROS_WORKON_INCREMENTAL_BUILD=1

CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"
# chromiumos-wide-profiling directory is in $SRC_URI, not in platform2.
CROS_WORKON_SUBTREE="common-mk"

PLATFORM_SUBDIR="chromiumos-wide-profiling"

inherit cros-workon platform

DESCRIPTION="quipper: chromiumos wide profiling"
HOMEPAGE="http://www.chromium.org/chromium-os/profiling-in-chromeos"
GIT_SHA1="7cdba5746e58a5a103262472f379d378b5a64c31"
SRC="quipper-${GIT_SHA1}.tar.gz"
SRC_URI="gs://chromeos-localmirror/distfiles/${SRC}"
SRC_DIR="src/${PN}"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	>=dev-cpp/gflags-2.0
	>=dev-libs/glib-2.30
	dev-libs/openssl:=
	dev-libs/protobuf:=
	dev-libs/re2
	dev-util/perf
"

DEPEND="${RDEPEND}
	chromeos-base/protofiles
	test? ( app-shells/dash )
"

src_unpack() {
	platform_src_unpack
	mkdir "${S}"

	pushd "${S}" >/dev/null
	unpack ${SRC}
	mv "${SRC_DIR}"/{.[!.],}* ./ || die
	epatch "${FILESDIR}"/quipper-disable-flaky-tests.patch
	popd >/dev/null
}

src_compile() {
	# ARM tests run on qemu which is much slower. Exclude some large test
	# data files for non-x86 boards.
	if use x86 || use amd64 ; then
		append-cppflags -DTEST_LARGE_PERF_DATA
	fi

	platform_src_compile
}

src_install() {
	dobin "${OUT}"/quipper
}

platform_pkg_test() {
	local tests=(
		integration_tests
		perf_recorder_test
		unit_tests
	)
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}" "1"
	done
}
