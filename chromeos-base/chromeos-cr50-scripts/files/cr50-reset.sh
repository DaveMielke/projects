#!/bin/bash
# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# This script is a wrapper around gsctool. It creates and displays a
# qrcode from the challenge string returned by gsctool. The cr50
# is reset when a valid authorization code is entered.

# RMA Reset Authorization parameters.
# - URL of Reset Authorization Server.
RMA_SERVER="https://www.google.com/chromeos/partner/console/cr50reset/"
RMA_SERVER="${RMA_SERVER}request?challenge="
# - Number of retries before giving up.
MAX_RETRIES=3
# - Time in seconds to delay before generating another qrcode.
RETRY_DELAY=10

display_leave_dev_mode_message() {
  # Checks if GBB_FLAG_FORCE_DEV_SWITCH_ON (0x8) is set.
  local tmp_file="$(mktemp)"
  flashrom -p host -i GBB -r "${tmp_file}" > /dev/null 2>&1
  local flags="$(futility gbb -g --flags "${tmp_file}" | egrep -o "0x[0-9]+")"
  # Display message only when the flag is not set.
  if [ $(( ${flags} & 0x8 )) -eq 0 ]; then
    echo ""
    echo "After RMA reset, the system will reboot and leave developer mode."
    echo "To boot the USB shim again, please re-enter developer mode and"
    echo "boot from USB in recovery mode."
    echo ""
  fi
  rm -f "${tmp_file}"
}

cr50_reset() {
  # Make sure frecon is running.
  local frecon_pid="$(cat /run/frecon/pid)"

  # This is the path to the pre-chroot filesystem. Since frecon is started
  # before the chroot, all files that frecon accesses must be copied to
  # this path.
  local chg_str_path="/proc/${frecon_pid}/root"

  if [ ! -d "${chg_str_path}" ]; then
    echo "frecon not running. Can't display qrcode."
    return 1
  fi

  # Make sure qrencode is installed.
  if ! command -v qrencode > /dev/null; then
    echo "qrencode is not installed."
    return 1
  fi

  # Make sure gsctool is installed.
  if ! command -v gsctool > /dev/null; then
    echo "gsctool is not installed."
    return 1
  fi

  # Get HWID and replace whitespace with underscore.
  local hwid="$(crossystem hwid 2>/dev/null | sed -e 's/ /_/g')"

  # Get challenge string and remove "Challenge:".
  local ch="$(gsctool -t -r | sed -e 's/.*://g')"

  # Test if we have a challenge.
  if [ -z "${ch}" ]; then
    echo "Challenge wasn't generated. CR50 might need updating."
    return 1
  fi

  # Display the challenge.
  echo "Challenge:"
  echo "${ch}"

  # Remove whitespace from challenge.
  ch="$(echo "${ch}" | sed -e 's/ //g')"

  # Calculate challenge string.
  local chstr="${RMA_SERVER}${ch}&hwid=${hwid}"

  # Create qrcode and display it.
  qrencode -o "${chg_str_path}/chg.png" "${chstr}"
  printf "\033]image:file=/chg.png;scale=2\033\\" > /run/frecon/vt0

  # Display instructions to boot from USB shim again if the system will
  # leave developer mode after RMA reset.
  display_leave_dev_mode_message

  local n=0
  local ac
  local status
  while [ ${n} -lt ${MAX_RETRIES} ]; do
    # Read authorization code. Show input in uppercase letters.
    printf "Enter authorization code: "
    stty olcuc
    read -e ac
    stty -olcuc

    # The input string is still lowercase. Convert to uppercase.
    ac_uppercase="$(echo "${ac}" | tr 'a-z' 'A-Z')"

    # Test authorization code.
    if gsctool -t -r "${ac_uppercase}"; then
      return 0
    fi

    echo "Invalid authorization code. Please try again."
    echo

    : $(( n += 1 ))
    if [ ${n} -eq ${MAX_RETRIES} ]; then
      echo "Number of retries exceeded. Another qrcode will generate in 10s."
      local m=0
      while [ ${m} -lt ${RETRY_DELAY} ]; do
        printf "."
        sleep 1
        : $(( m += 1 ))
      done
      echo
    fi
  done
}

main() {
  cr50_reset
  if [ $? -ne 0 ]; then
    echo "Cr50 Reset Error."
  fi
}

main "$@"
