# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="27ef01c9953290d2609d07fc8e2b6689341494df"
CROS_WORKON_TREE=("96ecb2dad8cd853305974b8e506a17e386c4ee60" "038110baed84299f142f0b1a11c75ae402ac712a" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk arc/removable-media .gn"

inherit cros-workon

DESCRIPTION="Container to run Android's removable-media daemon."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/arc/removable-media"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="chromeos-base/mount-passthrough
	!<chromeos-base/chromeos-cheets-scripts-0.0.2-r470
"

src_install() {
	insinto /etc/init
	doins arc/removable-media/arc-removable-media.conf
	doins arc/removable-media/arc-removable-media-default.conf
	doins arc/removable-media/arc-removable-media-read.conf
	doins arc/removable-media/arc-removable-media-write.conf
}
