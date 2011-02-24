# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI="2"
inherit eutils cros-binary

# Synaptics touchpad generic eclass.
IUSE="is_touchpad ps_touchpad"

RDEPEND=""
DEPEND="${RDEPEND}"

CROS_BINARY_INSTALL_FLAGS="--strip-components=1"

export_uri() {
	local XORG_VERSION_STRING
	local XORG_VERSION
	local X_VERSION

	XORG_VERSION_STRING=$(grep "XORG_VERSION_CURRENT" "$ROOT/usr/include/xorg/xorg-server.h")
	XORG_VERSION_STRING=${XORG_VERSION_STRING/#\#define*XORG_VERSION_CURRENT}
	XORG_VERSION=$(($XORG_VERSION_STRING))
	if [ $XORG_VERSION -ge 10903000 ]; then
		X_VERSION=1.9
	else
		X_VERSION=1.7
	fi
	CROS_BINARY_URI="ssh://synaptics-private@git.chromium.org:6222/home/synaptics-private/${CATEGORY}/${PN}/${PN}-xorg-${X_VERSION}-${PV}-${PR}.tar.gz"
}

function synaptics-touchpad_src_unpack() {
	export_uri
	cros-binary_src_unpack
}

function synaptics-touchpad_src_install() {
	# Currently you must have files/* in each ebuild that inherits
	# from here. These files will go away soon after they are pushed
	# into the synaptics tarball.
	export_uri
	cros-binary_src_install

	install --mode=0755 "${FILESDIR}/tpcontrol_syncontrol" "${D}/opt/Synaptics/bin"

	# link the appropriate config files for the type of trackpad
	if use is_touchpad && use ps_touchpad; then
	   die "Specify only one type of touchpad"
	elif use is_touchpad; then
	   dosym HKLM_Kernel_IS /opt/Synaptics/HKLM_Kernel || die
	   dosym HKLM_User_IS /opt/Synaptics/HKLM_User || die
	elif use ps_touchpad; then
	   dosym HKLM_Kernel_PS /opt/Synaptics/HKLM_Kernel || die
	   dosym HKLM_User_PS /opt/Synaptics/HKLM_User || die
	else
	   die "Type of touchpad not specified"
	fi

}

