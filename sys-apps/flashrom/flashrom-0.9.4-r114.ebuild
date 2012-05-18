# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/flashrom/flashrom-0.9.4.ebuild,v 1.5 2011/09/20 16:03:21 nativemad Exp $
CROS_WORKON_COMMIT="469707f0d9b7d81b6c6bb2cace13f09db70f4382"
CROS_WORKON_TREE="5bdd86e502b10c3a47156ec7336dfcc06a2bd369"

EAPI="3"
CROS_WORKON_PROJECT="chromiumos/third_party/flashrom"

inherit cros-workon toolchain-funcs

DESCRIPTION="Utility for reading, writing, erasing and verifying flash ROM chips"
HOMEPAGE="http://flashrom.org/"
#SRC_URI="http://download.flashrom.org/releases/${P}.tar.bz2"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE="+atahpt +bitbang_spi +buspirate_spi dediprog +drkaiser
+dummy ft2232_spi +gfxnvidia +internal +nic3com +nicintel +nicintel_spi
+nicnatsemi +nicrealtek +ogp_spi +rayer_spi
+satasii +satamv +serprog +wiki static"

COMMON_DEPEND="atahpt? ( sys-apps/pciutils )
	dediprog? ( virtual/libusb:0 )
	drkaiser? ( sys-apps/pciutils )
	ft2232_spi? ( dev-embedded/libftdi )
	gfxnvidia? ( sys-apps/pciutils )
	internal? ( sys-apps/pciutils )
	nic3com? ( sys-apps/pciutils )
	nicintel? ( sys-apps/pciutils )
	nicintel_spi? ( sys-apps/pciutils )
	nicnatsemi? ( sys-apps/pciutils )
	nicrealtek? ( sys-apps/pciutils )
	rayer_spi? ( sys-apps/pciutils )
	satasii? ( sys-apps/pciutils )
	satamv? ( sys-apps/pciutils )
	ogp_spi? ( sys-apps/pciutils )"
RDEPEND="${COMMON_DEPEND}
	internal? ( sys-apps/dmidecode )"
DEPEND="${COMMON_DEPEND}
	sys-apps/diffutils"

_flashrom_enable() {
	local c="CONFIG_${2:-$(echo $1 | tr [:lower:] [:upper:])}"
	args+=" $c=`use $1 && echo yes || echo no`"
}
flashrom_enable() {
	local u
	for u in "$@" ; do _flashrom_enable $u ; done
}

src_compile() {
	local progs=0
	local args=""

	# Programmer
	flashrom_enable \
		atahpt bitbang_spi buspirate_spi dediprog drkaiser \
		ft2232_spi gfxnvidia nic3com nicintel nicintel_spi nicnatsemi nicrealtek \
		ogp_spi rayer_spi \
		satasii satamv serprog \
		internal dummy
	_flashrom_enable wiki PRINT_WIKI
	_flashrom_enable static STATIC

	# You have to specify at least one programmer, and if you specify more than
	# one programmer you have to include either dummy or internal in the list.
	for prog in ${IUSE//[+-]} ; do
		case ${prog} in
			internal|dummy|wiki) continue ;;
		esac

		use ${prog} && : $(( progs++ ))
	done
	if [ $progs -ne 1 ] ; then
		if ! use internal && ! use dummy ; then
			ewarn "You have to specify at least one programmer, and if you specify"
			ewarn "more than one programmer, you have to enable either dummy or"
			ewarn "internal as well.  'internal' will be the default now."
			args+=" CONFIG_INTERNAL=yes"
		fi
	fi

	tc-export AR CC RANLIB
	# WARNERROR=no, bug 347879
	emake WARNERROR=no ${args} || die
}

src_install() {
	dosbin flashrom || die
	doman flashrom.8
	dodoc ChangeLog README
}
