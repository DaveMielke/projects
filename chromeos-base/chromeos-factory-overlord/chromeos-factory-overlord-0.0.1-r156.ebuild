# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="98e8f1185016f661dcb42d887f2fd55f34ad2fd7"
CROS_WORKON_TREE="98c47d554020a74915a0c22e4bc350f35ecba7b6"
inherit cros-workon

CROS_WORKON_PROJECT="chromiumos/platform/factory"
CROS_WORKON_LOCALNAME="factory"
SRC_URI="gs://chromeos-localmirror/distfiles/overlord-deps-0.0.1.tar.gz"

DESCRIPTION="Overlord factory monitor"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="static"

RDEPEND=""
DEPEND="dev-lang/go"

src_unpack() {
	cros-workon_src_unpack

	mkdir -p factory/build
	cd factory/build
	unpack ${A}
}

src_compile() {
	emake -C go/src/overlord DEPS=false STATIC=$(usex static true false)
}

src_install() {
	dobin go/bin/overlordd
	dobin go/bin/ghost

	insinto /usr/share/overlord
	doins -r go/src/overlord/app
}
