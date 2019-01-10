# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="bbd5ea22ef9f8e109e363b26958d9a2fc8921f0f"
CROS_WORKON_TREE="3c21ded27c4b5eccf1c33467712ac8f96a603752"
CROS_WORKON_PROJECT="chromiumos/platform/webplot"

PYTHON_COMPAT=( python2_7 )
inherit cros-constants cros-workon distutils-r1

DESCRIPTION="Web drawing tool for touch devices"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/webplot/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

src_unpack() {
	default
	cros-workon_src_unpack
	TARGET_PACKAGE="webplot/remote"
	TARGET_SRC_PATH="${CHROOT_SOURCE_ROOT}/src/platform"
	pushd "${S}/${TARGET_PACKAGE}"
	# Copy the real files/directories pointed to by symlinks.
	for f in *; do
		content=$(readlink $f)
		if [ -n "$content" ]; then
			rm -f $f
			SRC_SUBPATH=${content##.*\./}
			cp -pr "${TARGET_SRC_PATH}/${SRC_SUBPATH}" .
		fi
	done
	popd
}

src_install() {
	distutils-r1_src_install
	exeinto /usr/local/bin
	newexe webplot.sh webplot
}
