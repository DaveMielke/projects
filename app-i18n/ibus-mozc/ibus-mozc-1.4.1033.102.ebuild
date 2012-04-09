# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
inherit eutils flag-o-matic python toolchain-funcs

DESCRIPTION="The Mozc engine for IBus Framework"
HOMEPAGE="http://code.google.com/p/mozc"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/mozc-${PV}.tar.bz2"
LICENSE="BSD"
RDEPEND=">=app-i18n/ibus-1.2
         dev-libs/protobuf
         net-misc/curl"
DEPEND="${RDEPEND}"
SLOT="0"
KEYWORDS="amd64 x86 arm"
BUILDTYPE="${BUILDTYPE:-Release}"
BRANDING="${BRANDING:-Mozc}"

src_prepare() {
  cd "mozc-${PV}" || die
  # TODO(nona): Remove the patch when we upgrade mozc to the next version, 1.5.
  epatch "${FILESDIR}"/${P}-arm-build-fix.patch
}

src_configure() {
  cd "mozc-${PV}" || die
  # Generate make files
  export GYP_DEFINES="chromeos=1 use_libzinnia=0"
  export BUILD_COMMAND="emake"

  $(PYTHON) build_mozc.py gyp --gypdir="third_party/gyp" \
      --use_libprotobuf \
      --target_platform="ChromeOS" \
      --branding="${BRANDING}" --channel_dev=0 || die
}

src_compile() {
  cd "mozc-${PV}" || die
  # Create build tools for the host platform.
  CFLAGS="" CXXFLAGS="" $(PYTHON) build_mozc.py build_tools -c ${BUILDTYPE} \
      || die

  # Build artifacts for the target platform.
  tc-export CXX CC AR AS RANLIB LD
  $(PYTHON) build_mozc.py build unix/ibus/ibus.gyp:ibus_mozc -c ${BUILDTYPE} \
      || die
}

src_install() {
  cd "mozc-${PV}" || die
  exeinto /usr/libexec || die
  newexe "out_linux/${BUILDTYPE}/ibus_mozc" ibus-engine-mozc || die

  insinto /usr/share/ibus/component || die
  doins out_linux/${BUILDTYPE}/obj/gen/unix/ibus/mozc.xml || die

  cp "out_linux/${BUILDTYPE}/ibus_mozc" "${T}" || die
  $(tc-getSTRIP) --strip-unneeded "${T}"/ibus_mozc || die

  # Check the binary size to detect binary size bloat (which happend once due
  # typos in .gyp files).
  FILESIZE=`stat -c %s "${T}"/ibus_mozc`
  einfo "The binary size is ${FILESIZE}"
  test ${FILESIZE} -lt 25000000 \
      || die 'The binary size of mozc for Japanese is too big (more than ~25MB)'
  rm -f "${T}"/ibus_mozc
}

pkg_postinst() {
  ewarn "Don't forget to update the ebuild file for the official build if you"
  ewarn "update this ebuild file."
}
