# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

CROS_WORKON_COMMIT="3069de8ec80b6a3f282124955b13a7c7f7534df5"
CROS_WORKON_TREE=("6e9ff357f773b80ae395275d877f587c2567139f" "2d9765e611d086c435b5568d883a2648a4d620e5" "3d3cca54ee5b8b839061ae69b9c0dbdeb332840c" "46f18eb98a71a0ac18b9c48a249e4272c21f9394" "5c2248294883deddccbe51af67acd1a6b6840487")
CROS_WORKON_PROJECT="apps/libapps"
CROS_WORKON_LOCALNAME="../third_party/libapps"
CROS_WORKON_SUBTREE="libdot hterm nassh ssh_client terminal"

inherit cros-workon

DESCRIPTION="The Chromium OS Shell extension (the HTML/JS rendering part)"
HOMEPAGE="https://chromium.googlesource.com/apps/libapps/+/master/nassh/doc/chromeos-crosh.md"
# These are kept in sync with libdot.py settings.
NPM_HASH="6aa8e3885b83f646e15bd56f9f53b97a481fe1907da55519fd789ca755d9eca5"
SRC_URI="
	https://storage.googleapis.com/chromium-nodejs/10.15.3/3f578b6dec3fdddde88a9e889d9dd5d660c26db9
	https://storage.googleapis.com/chromeos-localmirror/secureshell/distfiles/node_modules-${NPM_HASH}.tar.xz
"

# The archives above live on Google maintained sites.
RESTRICT="nomirror"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="!<chromeos-base/common-assets-0.0.2"

e() {
	echo "$@"
	"$@" || die
}

src_compile() {
	export VCSID="${CROS_WORKON_COMMIT:-${PF}}"
	e ./nassh/bin/mkcrosh.sh
}

src_install() {
	local dir="/usr/share/chromeos-assets/crosh_builtin"
	dodir "${dir}"
	unzip -d "${D}${dir}" nassh/dist/zip/crosh*.zip || die
}
