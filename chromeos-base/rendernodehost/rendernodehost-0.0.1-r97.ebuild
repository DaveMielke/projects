# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

CROS_WORKON_COMMIT="cf30cd68a6008d10036091c774699d243d7d8a9c"
CROS_WORKON_TREE=("473665059c4645c366e7d3f0dfba638851176adc" "83f92c03f9771ae16c62f56a92a44ca4fc111ec2" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk rendernodehost .gn"

PLATFORM_SUBDIR="rendernodehost"
WANT_LIBCHROME="no"

inherit cros-workon platform

DESCRIPTION="host service for render node forwarding"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/rendernodehost/"

LICENSE="BSD-Google"
KEYWORDS="*"

DEPEND="x11-libs/libdrm:="

src_install() {
	dolib.a "${OUT}"/librendernodehost.a
}
