# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/baselayout/baselayout-2.0.1.ebuild,v 1.1 2009/05/24 19:47:02 vapier Exp $

inherit useradd multilib

DESCRIPTION="Filesystem baselayout and init scripts (Modified for Chromium OS)"
HOMEPAGE="http://src.chromium.org/"
SRC_URI="mirror://gentoo/${P}.tar.bz2
	http://dev.gentoo.org/~vapier/dist/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

# NOTE: This is based on the baselayout-2.0.1 ebuild but has been completely
# stripped down to be Chromium OS specific for use in both the build
# environment and the target rootfs. For example, we pre-create the entire
# set of users needed in order to work around problems with UIDs when building
# into an alternate $ROOT. See comments in pkg_postinst()

# Adds a "daemon"-type user with no login or shell.
copy_or_add_daemon_user() {
	local username="$1"
	local uid="$2"
	copy_or_add_user "${username}" "*" $uid $uid "" /dev/null /bin/false
	copy_or_add_group "${username}" $uid
}

src_install() {
	emake \
		OS=$(use kernel_FreeBSD && echo BSD || echo Linux) \
		DESTDIR="${D}" \
		install || die

	# handle multilib paths.  do it here because we want this behavior
	# regardless of the C library that you're using.  we do explicitly
	# list paths which the native ldconfig searches, but this isn't
	# problematic as it doesn't change the resulting ld.so.cache or
	# take longer to generate.  similarly, listing both the native
	# path and the symlinked path doesn't change the resulting cache.
	local libdir ldpaths
	for libdir in $(get_all_libdirs) ; do
		ldpaths+=":/${libdir}:/usr/${libdir}:/usr/local/${libdir}"
	done
	dosed '/^LDPATH/d' /etc/env.d/00basic || die
	echo "LDPATH='${ldpaths#:}'" >> "${D}"/etc/env.d/00basic

	# We use our own sysctl.conf, which we'll probably hack on a lot
	# so just copy it inplace instead of using patches to avoid the
	# overhead of creating patches all the time.
	cp "${FILESDIR}"/sysctl.conf "${D}"/etc/sysctl.conf
	install -d "${D}"/etc/profile.d
	install -m 644 "${FILESDIR}"/xauthority.sh "${D}"/etc/profile.d/xauthority.sh

	# Remove files that don't make sense for Chromium OS
	for x in issue issue.logo ; do
		rm -f "${D}/etc/${x}"
	done

	# Some things (at least gcc-config) depend on /sbin/functions.sh.
	# TODO(tedbo): Remove this when we find a workaround.
	into /
	dosbin "${FILESDIR}/functions.sh"
	dosym "/sbin/functions.sh" "/etc/init.d/functions.sh"
}

pkg_postinst() {
	local x

	# We installed some files to /usr/share/baselayout instead of /etc to stop
	# (1) overwriting the user's settings
	# (2) screwing things up when attempting to merge files
	# (3) accidentally packaging up personal files with quickpkg
	# If they don't exist then we install them
	for x in master.passwd passwd shadow group fstab ; do
		[ -e "${ROOT}etc/${x}" ] && continue
		[ -e "${ROOT}usr/share/baselayout/${x}" ] || continue
		cp -p "${ROOT}usr/share/baselayout/${x}" "${ROOT}"etc
	done

	# Force shadow permissions to not be world-readable #260993
	for x in shadow ; do
		[ -e "${ROOT}etc/${x}" ] && chmod 0600 "${ROOT}etc/${x}"
	done

	# We explicitly add all of the users needed in the system here. The
	# build of Chromium OS uses a single build chroot environment to build
	# for various targets with distinct ${ROOT}. This causes two problems:
	#   1. The target rootfs needs to have the same UIDs as the build
	#      chroot so that chmod operations work.
	#   2. The portage tools to add a new user in an ebuild don't work when
	#      $ROOT != /
	# We solve this by having baselayout install in both the build and
	# target and pre-create all needed users. In order to support existing
	# build roots we copy over the user entries if they already exist.
	local system_user="chronos"
	local system_id="1000"
	local system_home="/home/${system_user}/user"

	local crypted_password='*'
	[ -r "${SHARED_USER_PASSWD_FILE}" ] &&
		crypted_password=$(cat "${SHARED_USER_PASSWD_FILE}")
	remove_user "${system_user}"
	add_user "${system_user}" "x" "${system_id}" \
		"${system_id}" "system_user" "${system_home}" /bin/sh
	remove_shadow "${system_user}"
	add_shadow "${system_user}" "${crypted_password}"

	copy_or_add_group "${system_user}" "${system_id}"
	copy_or_add_daemon_user "messagebus" 201  # For dbus
	copy_or_add_daemon_user "syslog" 202      # For rsyslog
	copy_or_add_daemon_user "ntp" 203
	copy_or_add_daemon_user "sshd" 204
	copy_or_add_daemon_user "pulse" 205       # For pulseaudio
	copy_or_add_daemon_user "polkituser" 206  # For policykit
	copy_or_add_daemon_user "tss" 207         # For trousers (TSS/TPM)
	copy_or_add_daemon_user "pkcs11" 208      # For opencryptoki
	copy_or_add_daemon_user "qdlservice" 209  # for QDLService
	copy_or_add_daemon_user "cromo" 210	  # For cromo (modem manager)
	copy_or_add_daemon_user "cashew" 211      # For cashew (network usage)
	copy_or_add_daemon_user "ipsec" 212       # For strongswan/ipsec VPN
	copy_or_add_daemon_user "cros-disks" 213  # For cros-disks
	copy_or_add_daemon_user "tor" 214         # For tor (anonymity service)
	# Reserve some UIDs/GIDs between 300 and 349 for sandboxing FUSE-based
	# filesystem daemons.
	copy_or_add_daemon_user "ntfs-3g" 300     # For ntfs-3g

	# The system_user needs to be part of the audio and video groups.
	test $(grep -e "^audio\:" "${ROOT}/etc/group" | \
		grep "${system_user}") || \
		sed -i "{ s/audio::18:\(.*\)/audio::18:\1,${system_user}/ }" \
			"${ROOT}/etc/group"
	test $(grep -e "^video\:" "${ROOT}/etc/group" | \
		grep "${system_user}") || \
		sed -i "{ s/video::27:\(.*\)/video::27:\1,${system_user}/ }" \
			"${ROOT}/etc/group"

	# The root, ipsec and ${system_user} users must be in the pkcs11 group,
	# which must have the group id 208.
	sed -i "{ s/pkcs11:x:.*/pkcs11:x:208:root,ipsec,${system_user}/ }" \
		"${ROOT}/etc/group"

	# Some default directories. These are created here rather than at
	# install because some of them may already exist and have mounts.
	for x in /dev /home /media \
		/mnt/stateful_partition /proc /root /sys /var/lock; do
		[ -d "${ROOT}/$x" ] && continue
		install -d --mode=0755 --owner=root --group=root "${ROOT}/$x"
	done
}
