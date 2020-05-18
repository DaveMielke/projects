# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

if [[ -z ${_ARC_BUILD_CONSTANTS_ECLASS} ]]; then
_ARC_BUILD_CONSTANTS_ECLASS=1

# USE flags corresponding to different container versions.
ANDROID_CONTAINER_VERS=(
	android-container-pi
	android-container-qt
)

# USE flags corresponding to different VM versions.
ANDROID_VM_VERS=(
	android-vm-pi
	android-vm-rvc
	android-vm-master
)

IUSE="arcpp arcvm"
IUSE="${IUSE} cheets"
IUSE="${IUSE} ${ANDROID_CONTAINER_VERS[*]}"
IUSE="${IUSE} ${ANDROID_VM_VERS[*]}"

REQUIRED_USE="
	cheets? (
		|| ( arcpp arcvm )
		arcpp? ( ^^ ( ${ANDROID_CONTAINER_VERS[*]} ) )
		arcvm? ( ^^ ( ${ANDROID_VM_VERS[*]} ) )
	)
	!cheets? ( !arcpp !arcvm )
	!arcpp? ( ${ANDROID_CONTAINER_VERS[*]/#/!} )
	!arcvm? ( ${ANDROID_VM_VERS[*]/#/!} )
"

# @FUNCTION: arc-build-constants-configure
# @DESCRIPTION:
# Configures ARC variables for container or VM build:
# - ARC_PREFIX: Path to root directory of ARC installation relative to sysroot.
# - ARC_VM_PREFIX: Path to root directory of ARCVM installation relative to sysroot.
# - ARC_CONTAINER_PREFIX: Path to root directory of ARC++ installation relative to sysroot.
# - ARC_VENDOR_DIR: Path to install directory for /vendor files relative to sysroot.
# - ARC_VM_VENDOR_DIR: Path to install directory for /vendor files relative to sysroot for ARCVM.
# - ARC_CONTAINER_VENDOR_DIR: Path to install directory for /vendor files relative to sysroot for ARC++.
# - ARC_ETC_DIR: Path to install directory for /etc files relative to sysroot.
# - ARC_VM_ETC_DIR: Path to install directory for /etc files relative to sysroot for ARCVM.
# - ARC_CONTAINER_ETC_DIR: Path to install directory for /etc files relative to sysroot for ARC++.
# - ARC_VERSION_CODENAME: Selected Android version.
arc-build-constants-configure() {
	if ! use cheets; then
		# ARC is unavailable when the cheets flag is not set.
		return
	fi

	# Use only in packages that are specific to either ARC++ or ARCVM.
	ARC_VM_PREFIX="/opt/google/vms/android"
	ARC_CONTAINER_PREFIX="/opt/google/containers/android"

	if use arcpp && use arcvm; then
		# When building ARC++ and ARCVM together, the path to which common packages
		# will install to will point to a union path jointed during build_images.
		ARC_PREFIX="/build/rootfs/opt/google/union/android"
		ARC_VM_PREFIX="/usr/local/vms/android"
	elif use arcvm; then
		ARC_PREFIX="${ARC_VM_PREFIX}"
	else
		ARC_PREFIX="${ARC_CONTAINER_PREFIX}"
	fi

	# Always finalize *_DIR's only after setting the PREFIX*'s to allow for
	# interposition of the locations.
	ARC_VENDOR_DIR="/build/rootfs${ARC_PREFIX}/vendor"
	ARC_ETC_DIR="/build/rootfs${ARC_PREFIX}/etc"

	ARC_VM_VENDOR_DIR="/build/rootfs${ARC_VM_PREFIX}/vendor"
	ARC_VM_ETC_DIR="/build/rootfs${ARC_VM_PREFIX}/etc"

	ARC_CONTAINER_VENDOR_DIR="/build/rootfs${ARC_CONTAINER_PREFIX}/vendor"
	ARC_CONTAINER_ETC_DIR="/build/rootfs${ARC_CONTAINER_PREFIX}/etc"
}

fi
