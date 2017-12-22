# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="Install dynamic media profiles on ARC++"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RDEPEND="
	media-libs/arc-camera-profile"
DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_install() {
	insinto /etc/camera/
	doins "${FILESDIR}/media_profiles.xml"

	# Default media profiles is installed into vendor image.
	# /etc/media_profiles.xml in container is a symbolic link to vendor image.
	# In order to dynamic generated the profile, we have to install the file
	# into /oem partition. Create a symbolic link in vendor image to redirect
	# profiles correctly.
	dosym "/oem/etc/media_profiles.xml" \
		"/opt/google/containers/android/vendor/etc/media_profiles.xml"
}
