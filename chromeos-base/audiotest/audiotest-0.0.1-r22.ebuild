# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="2ff17232be7ec4a7d87f861abe1c52c7d13e35d8"
CROS_WORKON_TREE="dadecb96fc2a17761a926c732962f93857250356"
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
	dobin cras_api_test
	dobin test_tones
	dobin looptest
	dobin loopback_latency
	popd >/dev/null
}
