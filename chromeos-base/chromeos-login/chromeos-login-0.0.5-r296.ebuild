# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="8c0ff3744c6e3c6921d987b40504f7a0334e8a9d"
CROS_WORKON_PROJECT="chromiumos/platform/login_manager"

KEYWORDS="arm amd64 x86"

inherit cros-debug cros-workon multilib toolchain-funcs

DESCRIPTION="Login manager for Chromium OS."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"

# Boards whose USE flags we write for session_manager_setup.sh.
BOARDS=(
	daisy
	ironhide
	x86-alex
	x86-alex_he
	x86-mario
	x86-zgb
	x86-zgb_he
)
BOARD_USE_PREFIX="board_use_"
BOARD_USE_FLAGS=${BOARDS[@]/#/${BOARD_USE_PREFIX}}

IUSE="-asan -aura -is_desktop -new_power_button test -touchui"
for flag in $BOARD_USE_FLAGS; do
	IUSE="$IUSE $flag"
done

RDEPEND="chromeos-base/chromeos-cryptohome
	chromeos-base/chromeos-minijail
	chromeos-base/metrics
	dev-libs/dbus-glib
	dev-libs/glib
	dev-libs/nss
	dev-libs/protobuf
	x11-libs/gtk+"

DEPEND="${RDEPEND}
	>=chromeos-base/libchrome-85268:0[cros-debug=]
	chromeos-base/libchrome_crypto
	chromeos-base/protofiles
	chromeos-base/system_api
	dev-cpp/gmock
	sys-libs/glibc
	test? ( dev-cpp/gtest )"

CROS_WORKON_LOCALNAME="$(basename ${CROS_WORKON_PROJECT})"

# Takes a USE flag and a filename.
# If the USE flag is set, appends it and a trailing newline to the file.
append_use_flag_if_set() {
	if use "$1"; then
		echo "$1" >> "$2"
	fi
}

src_compile() {
	tc-export CXX LD PKG_CONFIG
	cros-debug-add-NDEBUG
	emake login_manager || die "chromeos-login compile failed."

	# Build locale-archive for Chrome. This is a temporary workaround for
	# crbug.com/116999.
	# TODO(yusukes): Fix Chrome and remove the file.
	mkdir -p "${T}/usr/lib64/locale"
	localedef --prefix="${T}" -c -f UTF-8 -i en_US en_US.UTF-8 || die
}

src_test() {
	tc-export CXX LD PKG_CONFIG
	cros-debug-add-NDEBUG

	emake tests || die "chromeos-login compile tests failed."
}

src_install() {
	into /
	dosbin "${S}/keygen"
	dosbin "${S}/session_manager_setup.sh"
	dosbin "${S}/session_manager"
	dosbin "${S}/xstart.sh"

	insinto /usr/share/dbus-1/interfaces
	doins "${S}/session_manager.xml"

	insinto /etc/dbus-1/system.d
	doins "${S}/SessionManager.conf"

	insinto /usr/share/dbus-1/services
	doins "${S}/org.chromium.SessionManager.service"

	insinto /usr/share/misc
	doins "${S}/recovery_ui.html"

	# TODO(yusukes): Fix Chrome and remove the file. See my comment above.
	insinto /usr/$(get_libdir)/locale
	doins "${T}/usr/lib64/locale/locale-archive"

	# For user session processes.
	dodir /etc/skel/log

	# Write a list of currently-set USE flags that session_manager_setup.sh can
	# read at runtime while constructing Chrome's command line.  If you need to
	# use a new flag, add it to $IUSE at the top of the file and list it here.
	local use_flag_file="${D}"/etc/session_manager_use_flags.txt
	local flag
	for flag in asan aura is_desktop new_power_button $BOARD_USE_FLAGS; do
		append_use_flag_if_set "${flag}" "${use_flag_file}"
	done
}
