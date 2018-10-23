# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

cros_pre_src_prepare_brltty_config() {
	epatch "${FILESDIR}"/${P}-Customize-retain-dots-for-Chrome-OS-and-ChromeVox.patch
	epatch "${FILESDIR}"/${P}-fix-ldflags.patch
	epatch "${FILESDIR}"/${P}-suppress-messages.patch
	epatch "${FILESDIR}"/${P}-sysmacros.patch
	epatch "${FILESDIR}"/${P}-tty0-openflags.patch
	epatch "${FILESDIR}"/${P}-udev-run-script.patch
}

cros_post_src_prepare_brltty_config() {
	# Upstream has a patch that touches the autogenerated
	# part of the udev rules file.  Run this script after
	# that patch is applied so it applies cleanly.
	# updusbdevs rewrites the autogenerated part.  The -nogeneric
	# flag accomplishes what the upstream patch does.
	# Also, some of the patches in cros_pre_src_prepare_brltty_config
	# modify the usb device definitions in the C source, and for those
	# to be picked up by updusbdevs, those patches need to be applied
	# before the below line.
	./updusbdevs -nogeneric udev:Autostart/Udev/rules || die
}

cros_post_src_install_brltty_config() {
	insinto /etc
	doins "${FILESDIR}"/brltty.conf
	exeinto $(get_udevdir)
	doexe "${FILESDIR}"/brltty
}
