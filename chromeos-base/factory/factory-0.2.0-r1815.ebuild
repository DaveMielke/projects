# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="6206a29d385d787dfe2551dd75978efddb91a384"
CROS_WORKON_TREE="5de05ce896b7095ff57df32963bac4ff0f9cecaa"
CROS_WORKON_PROJECT="chromiumos/platform/factory"
CROS_WORKON_LOCALNAME="platform/factory"
CROS_WORKON_OUTOFTREE_BUILD=1

# TODO(crbug.com/999876): Upgrade to Python 3 at some point.
PYTHON_COMPAT=( python3_{4,5,6,7} )

inherit cros-workon python-r1 cros-constants cros-factory

# External dependencies
LOCAL_MIRROR_URL=http://commondatastorage.googleapis.com/chromeos-localmirror/
WEBGL_AQUARIUM_URI=${LOCAL_MIRROR_URL}/distfiles/webgl-aquarium-20130524.tar.bz2

DESCRIPTION="Chrome OS Factory Software Platform"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/factory/"
SRC_URI="${WEBGL_AQUARIUM_URI}"
LICENSE="BSD-Google"
KEYWORDS="*"

DEPEND="virtual/chromeos-bsp-factory:=
	virtual/chromeos-regions:=
	dev-python/enum34:=
	dev-python/jsonrpclib:=
	dev-python/pyyaml:=
	dev-python/protobuf-python:=
"

BUILD_DIR="${WORKDIR}/build"

pkg_setup() {
	cros-workon_pkg_setup
	python_setup
}

src_prepare() {
	default
	# Need the lddtree from the chromite dir.
	export PATH="${CHROMITE_BIN_DIR}:${PATH}"
}

src_configure() {
	default

	# Export build settings
	export BOARD="${SYSROOT##*/}"
	export OUTOFTREE_BUILD="${CROS_WORKON_OUTOFTREE_BUILD}"
	export PYTHON="${EPYTHON}"
	export PYTHON_SITEDIR="${ESYSROOT}$(python_get_sitedir)"
	export SRCROOT="${CROS_WORKON_SRCROOT}"
	export TARGET_DIR=/usr/local/factory
	export WEBGL_AQUARIUM_DIR="${WORKDIR}/webgl_aquarium_static"
	export FROM_EBUILD=1

	# Support out-of-tree build.
	export BUILD_DIR="${WORKDIR}/build"

	# The path of bundle is defined in chromite/cbuildbot/commands.py
	export BUNDLE_DIR="${ED}/usr/local/factory/bundle"
}

src_unpack() {
	cros-workon_src_unpack
	default
}

src_install() {
	emake bundle
	insinto "${CROS_FACTORY_BOARD_RESOURCES_DIR}"
	doins "${BUILD_DIR}/resource/installer.tar"
}