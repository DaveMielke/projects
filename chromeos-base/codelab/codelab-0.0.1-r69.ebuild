# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="d5602869156a73875304375cb1e68f8b44ed4379"
CROS_WORKON_TREE=("d802ce3091795ebf52e92b317fe508d6d6a1eafc" "ab5ed6ee7cca0cb607dfb6eb4c41979095255519" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"
CROS_WORKON_SUBTREE="common-mk codelab .gn"

PLATFORM_SUBDIR="codelab"

inherit cros-workon platform

DESCRIPTION="Developer codelab for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/codelab/"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE=""

src_install() {
	dobin "${OUT}"/codelab
}

platform_pkg_test() {
	platform_test "run" "${OUT}/codelab_test"
}
