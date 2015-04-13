# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT=("1ce4b33a1ee94523eda07e85e6f639d9866c8793" "8f8e0c449a06f9b76028229cf7e412548df0483c")
CROS_WORKON_TREE=("f4dc36cca04064dcf6fa5f0fca301946a048cb3d" "03454a38e8b1f64f3b1636e2d9a86639c6ce272d")
CROS_WORKON_PROJECT=("chromiumos/platform/factory" "chromiumos/platform2")
CROS_WORKON_LOCALNAME=("factory" "platform2")
CROS_WORKON_DESTDIR=("${S}" "${S}/platform2")

inherit cros-workon python cros-constants

WEBGL_AQUARIUM_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/webgl-aquarium-20130524.tar.bz2"

DESCRIPTION="Chrome OS Factory Tools and Data"
HOMEPAGE="http://www.chromium.org/"
SRC_URI="${WEBGL_AQUARIUM_URI}"
LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="+autotest +build_tests"

DEPEND="virtual/chromeos-interface
	dev-python/pyyaml
	dev-libs/protobuf-python
	chromeos-base/chromeos-factory-board"

# The runtime dependency for factory test are satisfied in the test image
# because of the need of factory toolkit, which simply runs on top of a
# test image. Therefore, we only need chromeos-factory-board here.
RDEPEND="chromeos-base/chromeos-factory-board"

# Binaries from other packages (ex, chrome).
STRIP_MASK="*/chromedriver */selenium/*"

TARGET_DIR="/usr/local/factory"

src_unpack() {
	default
	cros-workon_src_unpack

	# Need to remove webgl_aquarium_static/ first because we have a README
	# file in it.
	local webgl_aquarium_path="${S}/py/test/pytests/webgl_aquarium_static"
	rm -rf ${webgl_aquarium_path}
	mv "${WORKDIR}/webgl_aquarium_static" "${webgl_aquarium_path%/*}" || die
}

src_install() {
	overlay_zip="${EROOT}usr/local/factory/bundle/shopfloor/overlay.zip"
	if [ -e "$overlay_zip" ]; then
		make_par_args="--add-zip $overlay_zip"
	else
		make_par_args=
	fi

	emake DESTDIR="${D}" TARGET_DIR="${TARGET_DIR}" \
		PYTHON_SITEDIR="${EROOT}/$(python_get_sitedir)" \
		PYTHON="$(PYTHON)" \
		MAKE_PAR_ARGS="$make_par_args" \
		par install bundle

	# Sanity check: make sure we can import stuff with only the
	# .par file.
	PYTHONPATH="${D}${TARGET_DIR}/bundle/shopfloor/factory.par" \
		"$(PYTHON)" -c "import cros.factory.test.state" || die

	dosym ../../../../local/factory/py $(python_get_sitedir)/cros/factory

	# Replace chromeos-common.sh symlink with the real file
	cp --remove-destination \
		"${S}/platform2/installer/share/chromeos-common.sh" \
		"${D}${TARGET_DIR}/bundle/factory_setup/lib/chromeos-common.sh" || die

	# Replace fmap.py symlink with the real file
	cp --remove-destination "${S}/py/gooftool/fmap.py" \
		"${D}${TARGET_DIR}/bundle/factory_setup/" || die

	# Directories used by Goofy.
	keepdir /var/factory/{,log,state,tests}

	# Install factory test enabled tag
	touch "${D}${TARGET_DIR}/enabled"

	# Make sure everything is group- and world-readable.
	chmod -R go=rX "${D}${TARGET_DIR}"
}

pkg_postinst() {
	python_mod_optimize ${TARGET_DIR}/py
}
