# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
CROS_WORKON_COMMIT="78209a689f9581939d55bd0a72b2e001c1c5bb29"
CROS_WORKON_TREE="e89f6e3f114052768d2969eb1dd27c48df67fb99"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="init/upstart/test-init"

inherit cros-workon

DESCRIPTION="Additional upstart jobs that will be installed on test images"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/init/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

src_unpack() {
	cros-workon_src_unpack
	S+="/init"
}

src_install() {
	insinto /etc/init
	doins upstart/test-init/*.conf

	insinto /usr/share/cros
	doins upstart/test-init/*_utils.sh
}
