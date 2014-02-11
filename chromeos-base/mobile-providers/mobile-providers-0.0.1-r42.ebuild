# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="769aef475caeddaa74a6ab42d59a91778e1f8cae"
CROS_WORKON_TREE="75d8c3ffea4702af4eda9aa01ac30ba0ac56f426"
CROS_WORKON_PROJECT="chromiumos/third_party/mobile-broadband-provider-info"

inherit autotools cros-workon

DESCRIPTION="Database of mobile broadband service providers (with local modifications)"
HOMEPAGE="http://live.gnome.org/NetworkManager/MobileBroadband/ServiceProviders"

LICENSE="CC-PD"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang tools"
REQUIRED_USE="asan? ( clang )"

RDEPEND="!net-misc/mobile-broadband-provider-info
	>=dev-libs/glib-2.0"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9"

CROS_WORKON_LOCALNAME="../third_party/mobile-broadband-provider-info"

src_prepare() {
	eautoreconf
}

src_configure() {
	clang-setup-env
	cros-workon_src_configure $(use_enable tools)
}

src_compile() {
	xmllint --valid --noout serviceproviders.xml || \
		die "XML document is not well-formed or is not valid"
	emake clean-generic
	emake
}

src_test() {
	emake check
	if use x86 || use amd64 ; then
		gtester --verbose src/mobile_provider_unittest
	else
		echo "Skipping tests on non-x86 platform..."
	fi
}
