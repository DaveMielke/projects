# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="682cb03170c0fc03f0800537dfc6bde4eb54c7a6"
CROS_WORKON_TREE=("4c23cb26be092f90ba8160118d643548e3a14a89" "569dbe30775407ebff384419f65741554131d462" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk arc/scripts .gn"

inherit cros-workon

DESCRIPTION="ARC++/ARCVM common scripts."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/arc/scripts"

LICENSE="BSD-Google"
SLOT="0/0"
KEYWORDS="*"

IUSE="arcvm arcpp"
RDEPEND="app-misc/jq"
DEPEND=""

src_install() {
	if use arcpp; then
		dosbin arc/scripts/android-sh
	fi
	if use arcvm; then
		newsbin arc/scripts/android-sh-vm android-sh
	fi

	insinto /etc/init
	doins arc/scripts/arc-remove-data.conf
	doins arc/scripts/arc-stale-directory-remover.conf
}