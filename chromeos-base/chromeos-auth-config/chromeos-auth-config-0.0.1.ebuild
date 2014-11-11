# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="ChromiumOS-specific configuration files for pambase"
HOMEPAGE="http://www.chromium.org"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND=">=sys-auth/pambase-20090620.1-r7
	chromeos-base/vboot_reference"
DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_install() {
	# Chrome OS: sudo and vt2 are important for system debugging both in
	# developer mode and during development.  These two stanzas allow sudo and
	# login auth as user chronos under the following conditions:
	#
	# 1. password-less access:
	# - system in developer mode
	# - there is no passwd.devmode file
	# - there is no system-wide password set above.
	# 2. System-wide (/etc/shadow) password access:
	# - image has a baked in password above
	# 3. Developer mode password access
	# - user creates a passwd.devmode file with "chronos:CRYPTED_PASSWORD"
	# 4. System-wide (/etc/shadow) password access set by modifying /etc/shadow:
	# - Cases #1 and #2 will apply but failure will fall through to the
	#   inserted password.
	insinto /etc/pam.d
	doins "${FILESDIR}/chromeos-auth"

	dosbin "${FILESDIR}/is_developer_end_user"

	insinto /etc/init
	doins "${FILESDIR}"/hotkey-access.conf
}
