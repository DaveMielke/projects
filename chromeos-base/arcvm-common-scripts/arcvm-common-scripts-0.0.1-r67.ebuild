# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="f1d892b43c2170b8960364f75585484ed0a4448f"
CROS_WORKON_TREE=("b2d7995ab106fbf61493d108c2bfd78d1a721d83" "978d0f831d0c93f7e13fe8fdf8fb48ed88c2df31" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk arc/vm/scripts .gn"

inherit cros-workon

DESCRIPTION="ARCVM common scripts."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/arc/vm/scripts"

LICENSE="BSD-Google"
KEYWORDS="*"

RDEPEND="
	${RDEPEND}
	chromeos-base/arc-setup
	chromeos-base/arcvm-mount-media-dirs
"

src_install() {
	insinto /etc/init
	doins arc/vm/scripts/init/arcvm-fsverity-certs.conf
	doins arc/vm/scripts/init/arcvm-host.conf
	doins arc/vm/scripts/init/arcvm-per-board-features.conf
	doins arc/vm/scripts/init/arcvm-ureadahead.conf

	insinto /usr/share/arcvm
	doins arc/vm/scripts/init/config.json

	insinto /usr/share/arcvm/fsverity-certs
	doins arc/vm/scripts/init/certs/fsverity-release.x509.der
	doins arc/vm/scripts/init/certs/play_store_fsi_cert.der

	insinto /etc/dbus-1/system.d
	doins arc/vm/scripts/init/dbus-1/ArcVmScripts.conf
}