# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="5dfa7e731d18b6a52b44b696ee0ae3d68825d533"
CROS_WORKON_TREE=("1c07dc76ec4881aeccc6c6151786dc26bf5f73c0" "edfd3f31320ad47350b57529c06767b6c99b2985" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk verity .gn"

PLATFORM_SUBDIR="verity"

inherit cros-workon platform cros-common.mk

DESCRIPTION="File system integrity image generator for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/verity/"

LICENSE="BSD-Google GPL-2"
KEYWORDS="*"

src_install() {
	dolib.a "${OUT}"/libdm-bht.a
	insinto /usr/include/verity
	doins dm-bht.h dm-bht-userspace.h
	insinto /usr/include/verity
	cd include
	doins -r linux asm asm-generic crypto
	cd ..
	into /
	dobin "${OUT}"/verity
}