#!/bin/bash
# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Use this script to regenerate the artifacts needed by the test-dlc.

if [ -z "${BOARD}" ]; then
  echo "BOARD variable is unset." && exit 1
else
  echo "using BOARD='${BOARD}'"
fi

set -ex

TEMP="$(mktemp -d)"
BUILD_BOARD="/build/${BOARD}"
DLC_ROOTFS_META_DIR="rootfs_meta"
DLC_PAYLOADS_DIR="payloads"
DLC_IMAGE_DIR="build/rootfs/dlc"
DLC_PACKAGE="test-package"
DLC_PAYLOAD="dlcservice_test-dlc.payload"
LSB_RELEASE="etc/lsb-release"
UPDATE_ENGINE_CONF="etc/update_engine.conf"

# Creates files (truncated/hash/perm) in the files directory with given
# truncate size, name, and permissions.
generate_file() {
  local size="$1"
  local filepath="${DLC_FILES_DIR}/$2"
  local permissions="$3"
  truncate -s "${size}" "${filepath}" || die
  sha256sum "${filepath}" > "${filepath}.sum" || die
  chmod "${permissions}" "${filepath}" || die
  echo "${permissions}" > "${filepath}.perms" || die
}


mkdir -p "${DLC_PAYLOADS_DIR}" "${DLC_ROOTFS_META_DIR}"
for N in {1..2}; do
  DLC_ID="test${N}-dlc"
  DLC_PATH="${DLC_ID}/${DLC_PACKAGE}"
  DLC_FILES_DIR="${TEMP}/${DLC_IMAGE_DIR}/${DLC_ID}/${DLC_PACKAGE}/root"

  mkdir -p "${DLC_FILES_DIR}/dir"  "${TEMP}"/etc
  generate_file 12K "file1.bin" 0755
  generate_file 24K "dir/file2.bin" 0700
  generate_file 24K "dir/file3.bin" 0444

  build_dlc  --install-root-dir "${TEMP}" --pre-allocated-blocks "10" \
      --version "1.0.0" --id "${DLC_ID}" --package "${DLC_PACKAGE}" \
      --name "Test${N} DLC" --build-package

  cp "${BUILD_BOARD}/${LSB_RELEASE}" "${TEMP}"/etc/
  cp "${BUILD_BOARD}/${UPDATE_ENGINE_CONF}" "${TEMP}"/etc/

  build_dlc --sysroot "${TEMP}" --rootfs "${TEMP}"

  cp -r "${TEMP}/opt/google/dlc"/* "${DLC_ROOTFS_META_DIR}/"

  PAYLOAD_NAME="${DLC_ID}_${DLC_PACKAGE}_${DLC_PAYLOAD}"
  cros_generate_update_payload \
      --tgt-image "${TEMP}/build/rootfs/dlc/${DLC_PATH}/dlc.img" \
      --output "${TEMP}/${PAYLOAD_NAME}"

  # Remove the AppID because it is static and nebraska won't be able to get it
  # when different boards pass different APP IDs.
  FIND_BEGIN="{\"appid\": \""
  FIND_END="_test"
  sed -i "s/${FIND_BEGIN}.*${FIND_END}/${FIND_BEGIN}${FIND_END}/" \
   "${TEMP}/${PAYLOAD_NAME}.json"

  cp "${TEMP}/${PAYLOAD_NAME}" "${TEMP}/${PAYLOAD_NAME}.json" "${DLC_PAYLOADS_DIR}/"

  sudo rm -rf "${TEMP}"
done
