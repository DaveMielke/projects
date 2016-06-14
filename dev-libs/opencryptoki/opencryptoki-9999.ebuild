# Copyright 2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/opencryptoki/opencryptoki-2.2.8.ebuild,v 1.1 2009/06/28 10:48:58 arfrever Exp $

EAPI="4"

CROS_WORKON_PROJECT="chromiumos/third_party/opencryptoki"

inherit cros-workon autotools eutils multilib toolchain-funcs

DESCRIPTION="PKCS#11 provider for IBM cryptographic hardware"
HOMEPAGE="http://sourceforge.net/projects/opencryptoki"

LICENSE="CPL-0.5"
SLOT="0"
KEYWORDS="~*"
IUSE="tpmtok tpm2"

RDEPEND="
	tpmtok? (
		!tpm2? ( app-crypt/trousers )
	)
	dev-libs/openssl"
DEPEND="${RDEPEND}"

src_prepare() {
	eautoreconf
	cros-workon_src_prepare
}

src_configure() {
	cros-workon_src_configure $(use_enable tpmtok)
}

src_install() {
	cros-workon_src_install

	# tpmtoken_* binaries expect to find the libraries in /usr/lib/.
	local libdir="/usr/$(get_libdir)"
	dosym opencryptoki/stdll/libpkcs11_sw.so.0.0.0 "${libdir}/libpkcs11_sw.so"
	dosym opencryptoki/stdll/libpkcs11_tpm.so.0.0.0 "${libdir}/libpkcs11_tpm.so"
	dosym opencryptoki/libopencryptoki.so.0.0.0 "${libdir}/libopencryptoki.so"
	dosym opencryptoki/stdll/libpkcs11_sw.so.0.0.0 "${libdir}/libpkcs11_sw.so.0"
	dosym opencryptoki/stdll/libpkcs11_tpm.so.0.0.0 "${libdir}/libpkcs11_tpm.so.0"
	dosym opencryptoki/libopencryptoki.so.0.0.0 "${libdir}/libopencryptoki.so.0"
}
