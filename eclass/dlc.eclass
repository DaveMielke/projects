# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# @MAINTAINER:
# Chromium OS System Services Team
# @AUTHOR
# The Chromium OS Authors <chromium-os-dev@chromium.org>
# @BUGREPORTS:
# Please report bugs via http://crbug.com/new
# @BLURB: Helper eclass for building DLC packages.
# @DESCRIPTION:
# Handles building the DLC image and metadata files and dropping them into
# locations where they can be picked up by the build process and hosted on
# Omaha, respectively.

if [[ -z "${_ECLASS_DLC}" ]]; then
_ECLASS_DLC="1"

inherit cros-constants

# Check for EAPI 6+.
case "${EAPI:-0}" in
[012345]) die "unsupported EAPI (${EAPI}) in eclass (${ECLASS})" ;;
esac

DEPEND="chromeos-base/update_engine"

# @ECLASS-VARIABLE: DLC_ID
# @REQUIRED
# @DEFAULT UNSET
# @DESCRIPTION:
# Unique ID for the DLC. Needed to generate metadata for imageloader. Used in
# creating directories for the image file and metadata.

# @ECLASS-VARIABLE: DLC_NAME
# @REQUIRED
# @DEFAULT UNSET
# @DESCRIPTION:
# Name of the DLC being built.

# @ECLASS-VARIABLE: DLC_VERSION
# @REQUIRED
# @DEFAULT UNSET
# @DESCRIPTION:
# Version of the DLC being built.

# @ECLASS-VARIABLE: DLC_FS_TYPE
# @REQUIRED
# @DEFAULT UNSET
# @DESCRIPTION:
# Specify the type of filesystem for the DLC image. Currently we only support
# squashfs.

# @ECLASS-VARIABLE: DLC_PREALLOC_BLOCKS
# @REQUIRED
# @DEFAULT UNSET
# @DESCRIPTION:
# The number of blocks to preallocate for each of the the DLC A/B partitions.
# Block size is 4 KiB.

# @ECLASS-VARIABLE: DLC_ARTIFACT_DIR
# @REQUIRED
# @DEFAULT UNSET
# @DESCRIPTION:
# Path to folder containing DLC artifacts to be packaged. Anything that should
# be included in the DLC image should be in this folder when dlc_src_install is
# called.

# @FUNCTION: dlc_src_install
# @DESCRIPTION:
# Packages DLC artifacts and installs metadata to /opt/google/${DLC_ID}. DLC
# images are moved to a temporary directory at /build/rootfs/dlc/${DLC_ID}.
dlc_src_install() {
	[[ -z "${DLC_ID}" ]] && die "DLC_ID undefined"
	[[ -z "${DLC_NAME}" ]] && die "DLC_NAME undefined"
	[[ -z "${DLC_VERSION}" ]] && die "DLC_VERSION undefined"
	[[ -z "${DLC_PREALLOC_BLOCKS}" ]] && die "DLC_PREALLOC_BLOCKS undefined"
	[[ -z "${DLC_ARTIFACT_DIR}" ]] && die "DLC_ARTIFACT_DIR undefined"

	local args=(
		--src-dir="${DLC_ARTIFACT_DIR}"
		--sysroot="${SYSROOT}"
		--install-root-dir="${D}"
		--pre-allocated-blocks="${DLC_PREALLOC_BLOCKS}"
		--version="${DLC_VERSION}"
		--id="${DLC_ID}"
		--name="${DLC_NAME}"
	)

	if [[ -n "${DLC_FS_TYPE}" ]]; then
		args+=( --fs-type="${DLC_FS_TYPE}" )
	fi

	"${CHROMITE_BIN_DIR}"/build_dlc "${args[@]}" \
		|| die "build_dlc failed to generate DLC image and metadata"
}

EXPORT_FUNCTIONS src_install

fi
