# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="ef0418303f5f2088bc00e66c9a9c9889a3baec95"
CROS_WORKON_TREE="ebc6d8d9d615390281f7d634347f29bcd54627db"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest

DESCRIPTION="Security autotests"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
# Enable autotest by default.
IUSE="-chromeless_tests +autotest -chromeless_tty +seccomp"

RDEPEND="
	!<chromeos-base/autotest-tests-0.0.3
"
DEPEND="${RDEPEND}"

IUSE_TESTS="
	!chromeless_tty? (
		!chromeless_tests? (
			+tests_security_EnableChromeTesting
			+tests_security_RendererSandbox
			+tests_security_RestartJob
		)
	)
	seccomp? (
		+tests_security_Minijail_seccomp
		+tests_security_SeccompSyscallFilters
	)
	+tests_security_AccountsBaseline
	+tests_security_AltSyscall
	+tests_security_ASLR
	+tests_security_ChromiumOSLSM
	+tests_security_CroshModules
	+tests_security_DbusMap
	+tests_security_DbusOwners
	+tests_security_Firewall
	+tests_security_HardlinkRestrictions
	+tests_security_HtpdateHTTP
	+tests_security_Minijail0
	+tests_security_ModuleLocking
	+tests_security_mprotect
	+tests_security_OpenFDs
	+tests_security_OpenSSLBlacklist
	+tests_security_OpenSSLRegressions
	+tests_security_ProtocolFamilies
	+tests_security_ptraceRestrictions
	+tests_security_ReservedPrivileges
	+tests_security_RootCA
	+tests_security_RootfsOwners
	+tests_security_RootfsStatefulSymlinks
	+tests_security_RuntimeExecStack
	+tests_security_SandboxedServices
	+tests_security_StatefulPermissions
	+tests_security_SuidBinaries
	+tests_security_SymlinkRestrictions
	+tests_security_SysLogPermissions
	+tests_security_SysVIPC
	x86? ( +tests_security_x86Registers )
	amd64? ( +tests_security_x86Registers )
"

IUSE="${IUSE} ${IUSE_TESTS}"

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
