# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="9e5ae90170911107dac7ccc22bcca95f3a32c962"
CROS_WORKON_TREE="253090242e9a9aa6ed54b894c4390b9a77acfe04"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_PROJECT="chromiumos/platform/audiotest"
inherit cros-workon

DESCRIPTION="Audio test tools"
HOMEPAGE="http://src.chromium.org"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"

RDEPEND="media-libs/alsa-lib
	media-sound/adhd"
DEPEND="${RDEPEND}"

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	asan-setup-env
	cros-workon_src_configure
}

src_compile() {
	cros-workon_src_compile
}

src_install() {
	cros-workon_src_install

	# Install built tools
	pushd "${OUT}" >/dev/null
	dobin src/alsa_api_test
	dobin src/alsa_helpers
	dobin src/audiofuntest
	dobin src/cras_api_test
	dobin src/loopback_latency
	popd >/dev/null
}
