# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_PROJECT="chromiumos/platform/libchrome_crypto"

KEYWORDS="~amd64 ~arm ~x86"

inherit cros-workon cros-debug toolchain-funcs

DESCRIPTION="Chrome crypto/ library extracted for use on Chrome OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"

RDEPEND=">=chromeos-base/libchrome-87480
	dev-libs/glib
	dev-libs/libevent
	dev-libs/nss
	x11-libs/gtk+"
DEPEND="${RDEPEND}
	dev-cpp/gtest"

src_prepare() {
	ln -s "${S}" "${WORKDIR}/crypto" &> /dev/null
	cp -p "${FILESDIR}/SConstruct" "${S}" || die
	epatch "${FILESDIR}/memory_annotation.patch" || die "libchrome prepare failed."
}

src_compile() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"

	scons || die "third_party/chrome compile failed."
}


src_install() {
	dodir "/usr/lib"
	dodir "/usr/include/crypto"

	insopts -m0644
	insinto "/usr/lib"
	doins "${S}/libchrome_crypto.a"

	insinto "/usr/include/crypto"
	doins "${S}/nss_util.h"
	doins "${S}/nss_util_internal.h"
	doins "${S}/rsa_private_key.h"
	doins "${S}/signature_creator.h"
	doins "${S}/signature_verifier.h"
}
