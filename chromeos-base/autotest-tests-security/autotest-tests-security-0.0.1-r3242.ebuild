# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="3689684cafa43e257b7a064024ee27fd49cc1249"
CROS_WORKON_TREE="f58f1386ef9514b3e7610214cedc7e2798b34f65"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest/files

inherit cros-workon autotest libchrome

DESCRIPTION="Security autotests"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
# Enable autotest by default.
IUSE="+autotest -chromeless_tests -chromeless_tty containers +seccomp selinux"

RDEPEND="
	!<chromeos-base/autotest-tests-0.0.3
	tests_security_Minijail0? ( sys-apps/keyutils )
	containers? (
		tests_security_Libcontainer? (
			chromeos-base/minijail
			chromeos-base/libcontainer
		)
	)
"
DEPEND="${RDEPEND}"

IUSE_TESTS="
	!chromeless_tty? (
		!chromeless_tests? (
			+tests_security_RendererSandbox
			+tests_security_SessionManagerDbusEndpoints
		)
	)
	seccomp? (
		+tests_security_Minijail_seccomp
		+tests_security_SeccompSyscallFilters
	)
	+tests_security_AltSyscall
	+tests_security_ASLR
	+tests_security_ChromiumOSLSM
	+tests_security_CpuVulnerabilities
	+tests_security_DbusOwners
	containers? (
		+tests_security_DeviceJail_AllowDeny
		+tests_security_DeviceJail_Detach
		+tests_security_DeviceJail_Filesystem
		+tests_security_DeviceJail_Lockdown
	)
	+tests_security_Firewall
	+tests_security_HardlinkRestrictions
	containers? ( +tests_security_Libcontainer )
	+tests_security_Minijail0
	+tests_security_ModuleLocking
	+tests_security_mprotect
	+tests_security_OpenFDs
	+tests_security_OpenSSLBlacklist
	+tests_security_ProtocolFamilies
	+tests_security_ptraceRestrictions
	+tests_security_RootCA
	+tests_security_RootfsOwners
	+tests_security_RootfsStatefulSymlinks
	containers? ( +tests_security_RunOci )
	+tests_security_RuntimeExecStack
	+tests_security_SandboxedServices
	selinux? ( +tests_security_SELinux )
	+tests_security_StatefulPartitionHardening
	+tests_security_StatefulPermissions
	+tests_security_SuidBinaries
	+tests_security_SymlinkRestrictions
	+tests_security_SysLogPermissions
	+tests_security_SysVIPC
	+tests_security_Usbguard
	x86? ( +tests_security_x86Registers )
	amd64? ( +tests_security_x86Registers )
"

IUSE="${IUSE} ${IUSE_TESTS}"

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
