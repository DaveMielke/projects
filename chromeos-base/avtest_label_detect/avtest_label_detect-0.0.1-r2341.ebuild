# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=4

CROS_WORKON_COMMIT="0ea2b837ac96c64b0d326d877483d75f9493b1a6"
CROS_WORKON_TREE="f6b55dc3c68efaf7965ecfc0185aa2a37765b907"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon eutils

DESCRIPTION="Autotest label detector for audio/video/camera"
HOMEPAGE="http://src.chromium.org"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan vaapi"

RDEPEND="vaapi? ( x11-libs/libva )"
DEPEND="${RDEPEND}"

src_unpack() {
	cros-workon_src_unpack
	S+="/avtest_label_detect"
}

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	export USE_VAAPI=$(usex vaapi)
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
	dobin avtest_label_detect
	popd >/dev/null

	insinto /etc
	doins "${S}"/avtest_label_detect.conf
}
