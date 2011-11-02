# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
#
# This file is a heavily edited version of the Gentoo original streamlined for
# ChromeOS base hardware.
EAPI=2
PYTHON_DEPEND="python? *"
inherit autotools eutils distutils flag-o-matic

DESCRIPTION="GPS daemon and library to interface GPS devices and clients"
HOMEPAGE="http://gpsd.berlios.de/"
SRC_URI="mirror://berlios/gpsd/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"

IUSE="dbus ntp python"

RDEPEND="dbus? ( >=sys-apps/dbus-0.94
		>=dev-libs/glib-2.6
		dev-libs/dbus-glib )
	 ntp? ( net-misc/ntp )
	 sys-fs/udev
	 virtual/libusb:1"

DEPEND="${RDEPEND}
	dev-lang/python"

# TODO(vbendeb): the below statement is a hack required to circumvent the
# build system deficiency: the linker default library path is specified in
# /build/<target>/make.conf, which causes the system libraries to be examined
# first by the linker, not last, as they ought to be.
#
# Once the build system is fixed the below statement will be removed to allow
# legitimate linker flag additions.
LDFLAGS=''

src_prepare() {
	# Drop extensions requiring Python.
	sed -i -e 's:^\s\+Extension("gps\.\(packet\|clienthelpers\)",.*$:#:' \
		setup.py || die "sed failed"

	epatch "${FILESDIR}"/2.96-pkgconfig.patch
	eautoreconf
}

src_configure() {
	local max_clients="5"
	local max_devices="2"
	local my_conf="--enable-shared --with-pic --enable-static"

	# For now leave out all GPS device protocols but the most basic
	local disabled_protocols="aivdm ashtech earthmate evermore fv18 garmin \
		garmintxt gpsclock itrax mtk3301 navcom ntrip oceanserver \
		oncore rtcm104v2 rtcm104v3 sirf superstar2 tnt tripmate tsip \
		ubx"

	use python && distutils_python_version

	for protocol in ${disabled_protocols}; do
		my_conf+=" --disable-${protocol}"
	done

	if use ntp; then
		my_conf="${my_conf} --enable-ntpshm --enable-pps"
	else
		my_conf="${my_conf} --disable-ntpshm --disable-pps"
	fi

	my_conf+=" --enable-max-devices=${max_devices}"
	my_conf+=" --enable-max-clients=${max_clients}"
	my_conf+=" --disable-ipv6"

	WITH_XSLTPROC=no WITH_XMLTO=no econf ${my_conf} \
		$(use_enable dbus)
}

src_compile() {
	emake -j1 || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
	insinto /etc/init || die "insinto failed"
	doins "${FILESDIR}/gpsd.conf" || die "doins failed"

	# TODO(vbendeb): to reintroduce support of USB devices plug in
	# populate udev rules here.
}
