# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="a3c760e5b3e3e646c202b23b9cf0d8593c0a0ff2"
CROS_WORKON_TREE="0ce9968bb46fa6ab7ae7fdae774cdb3bfa9374fe"
CROS_WORKON_PROJECT="chromiumos/platform/bmpblk"
CROS_WORKON_LOCALNAME="../platform/bmpblk"
CROS_WORKON_OUTOFTREE_BUILD="1"
CROS_WORKON_USE_VCSID="1"

# TODO(hungte) When "tweaking ebuilds by source repository" is implemented, we
# can generate this list by some script inside source repo.
CROS_BOARDS=(
	atlas
	auron_paine
	auron_yuna
	banjo
	buddy
	butterfly
	candy
	chell
	cid
	clapper
	cranky
	daisy
	daisy_snow
	daisy_spring
	daisy_skate
	dragonegg
	enguarde
	expresso
	eve
	falco
	fizz
	glados
	glimmer
	gnawty
	grunt
	guado
	hatch
	kalista
	kevin
	kip
	lars
	leon
	link
	lulu
	lumpy
	mccloud
	meowth
	monroe
	nami
	nautilus
	ninja
	nocturne
	nyan
	nyan_big
	octopus
	orco
	panther
	parrot
	peach_pi
	peach_pit
	peppy
	poppy
	quawks
	rammus
	reks
	rikku
	sarien
	scarlet
	soraka
	squawks
	stout
	stumpy
	sumo
	swanky
	tidus
	tricky
	veyron_brain
	veyron_danger
	veyron_jerry
	veyron_mickey
	veyron_minnie
	veyron_pinky
	veyron_romy
	winky
	wolf
	zako
	zoombini
)

inherit cros-workon cros-board

DESCRIPTION="Chrome OS Firmware Bitmap Block"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="detachable_ui"

src_prepare() {
	export BOARD="$(get_current_board_with_variant "${ARCH}-generic")"
	export VCSID

	# if fontconfig's cache is empty, prepare single use cache.
	# That's still faster than having each process (of which there
	# are many) re-scan the fonts
	if find /usr/share/cache/fontconfig -maxdepth 0 -type d -empty \
		-exec false {} +; then

		return
	fi

	TMPCACHE=$(mktemp -d)
	cat > $TMPCACHE/local-conf.xml <<-EOF
		<?xml version="1.0"?>
		<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
		<fontconfig>
		<cachedir>$TMPCACHE</cachedir>
		<include>/etc/fonts/fonts.conf</include>
		</fontconfig>
	EOF
	export FONTCONFIG_FILE=$TMPCACHE/local-conf.xml
	fc-cache -v
}

src_compile() {
	if use detachable_ui ; then
		export DETACHABLE_UI=1
	fi
	emake OUTPUT="${WORKDIR}" "${BOARD}"
	emake OUTPUT="${WORKDIR}/${BOARD}" ARCHIVER="/usr/bin/archive" archive
	if [[ "${BOARD}" == "${ARCH}-generic" ]]; then
		printf "1" > "${WORKDIR}/${BOARD}/vbgfx_not_scaled"
	fi
}

doins_if_exist() {
	local f
	for f in "$@"; do
		if [[ -r "${f}" ]]; then
			doins "${f}"
		fi
	done
}

src_install() {
	# Bitmaps need to reside in the RO CBFS only. Many boards do
	# not have enough space in the RW CBFS regions to contain
	# all image files.
	insinto /firmware/cbfs-ro-compress
	# These files aren't necessary for debug builds. When these files
	# are missing, Depthcharge will render text-only screens. They look
	# obviously not ready for release.
	doins_if_exist "${WORKDIR}/${BOARD}"/vbgfx.bin
	doins_if_exist "${WORKDIR}/${BOARD}"/locales
	doins_if_exist "${WORKDIR}/${BOARD}"/locale_*.bin
	doins_if_exist "${WORKDIR}/${BOARD}"/font.bin
	# This flag tells the firmware_Bmpblk test to flag this build as
	# not ready for release.
	doins_if_exist "${WORKDIR}/${BOARD}"/vbgfx_not_scaled
}
