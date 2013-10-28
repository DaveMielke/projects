# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_PROJECT="chromiumos/third_party/gobi3k-sdk"
CROS_WORKON_LOCALNAME=../third_party/gobi3k-sdk
inherit cros-workon toolchain-funcs

DESCRIPTION="SDK for Qualcomm Gobi 3000 modems"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

# TODO(jglasgow): remove realpath dependency
RDEPEND="
	|| ( >=sys-apps/coreutils-8.15 app-misc/realpath )
"

src_configure() {
	clang-setup-env
	cros-workon_src_configure
	tc-export LD CXX CC OBJCOPY AR
}
