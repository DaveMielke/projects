# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# ebuild generated by hackport 0.5.5

CABAL_FEATURES="lib profile haddock hoogle hscolour test-suite"
CABAL_EXTRA_CONFIGURE_FLAGS="--disable-executable-dynamic"
inherit haskell-cabal

MY_PN="ShellCheck"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Shell script analysis tool"
HOMEPAGE="https://www.shellcheck.net/"
SRC_URI="mirror://hackage/packages/archive/${MY_PN}/${PV}/${MY_P}.tar.gz"

LICENSE="GPL-3"
SLOT="0/${PV}"
KEYWORDS="*"
IUSE=""

DEPEND="dev-haskell/aeson:=[profile?]
	>=dev-haskell/mtl-2.2.1:=[profile?]
	>=dev-haskell/parsec-3.0:=[profile?]
	>=dev-haskell/quickcheck-2.7.4:2=[template_haskell,profile?]
	dev-haskell/regex-tdfa:=[profile?]
	dev-haskell/semigroups:=[profile?]
	>=dev-lang/ghc-7.8.2:=
	>=dev-haskell/cabal-1.18.1.3 <dev-haskell/cabal-2.5
"

S="${WORKDIR}/${MY_P}"

PATCHES=(
	"${FILESDIR}/${PN}-0.6.0-allowlocal.patch"
	"${FILESDIR}/${PN}-0.6.0-ebuild-vars.patch"
)

src_install() {
	cabal_src_install
	doman "${PN}.1"
}
