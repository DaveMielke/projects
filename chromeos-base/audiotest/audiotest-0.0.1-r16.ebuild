# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="16c4c1985f76853127abd7a5d82918cb509f9e11"
CROS_WORKON_TREE="b035ed046406673e51beaa2cdba3ccb024e3ed6e"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_PROJECT="chromiumos/platform/audiotest"
inherit cros-workon

DESCRIPTION="Audio test tools"
HOMEPAGE="http://src.chromium.org"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

RDEPEND="media-libs/alsa-lib
	media-sound/adhd
	sci-libs/fftw"
DEPEND="${RDEPEND}"

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	clang-setup-env
	cros-workon_src_configure
}

src_compile() {
	cros-workon_src_compile
}

src_install() {
	cros-workon_src_install

	# Install built tools
	pushd "${OUT}" >/dev/null
	dobin alsa_api_test
	dobin audiofuntest
	dobin test_tones
	dobin looptest
	dobin loopback_latency
	popd >/dev/null
}
