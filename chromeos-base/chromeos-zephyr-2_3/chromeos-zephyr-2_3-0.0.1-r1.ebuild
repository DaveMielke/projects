# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

CROS_WORKON_COMMIT=("fe6f27e9976877db256b22c594d60a8b2a2f035f" "c0d3c8004422b359fd2b6257a2c8e226eff54dd6" "542b2296e6d515b265e25c6b7208e8fea3014f90" "d1bc80d021f4ebc31f6e8b36f14b738cc26c7b03")
CROS_WORKON_TREE=("46f116d4821b939e2a61a9ee26d985f0e1d56c88" "40e802681769cf2c26f6e91a57b956690361b786" "c7037905e78a10c0920e0834700c2b5888c8d114" "cbfc2404c2e411908f5e8db083daf3041b408522")
CROS_WORKON_PROJECT=(
	"chromiumos/platform/zephyr-chrome"
	"chromiumos/third_party/zephyr"
	"chromiumos/third_party/zephyr/cmsis"
	"chromiumos/third_party/zephyr/hal_stm32"
)
CROS_WORKON_LOCALNAME=(
	"platform/zephyr-chrome"
	"third_party/zephyr/main/v2.3"
	"third_party/zephyr/cmsis/v2.3"
	"third_party/zephyr/hal_stm32/v2.3"
)
CROS_WORKON_DESTDIR=(
	"${S}/zephyr-chrome"
	"${S}/zephyr-base"
	"${S}/modules/cmsis"
	"${S}/modules/hal_stm32"
)

inherit cros-zephyr cros-workon

DESCRIPTION="Zephyr v2.3 based embedded controller firmware"
HOMEPAGE="http://src.chromium.org"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
