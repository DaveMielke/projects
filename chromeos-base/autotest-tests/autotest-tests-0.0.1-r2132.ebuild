# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="3e05cf896f22f2eb45475bd6495e2abe63653f0c"
CROS_WORKON_TREE="bf1457062ed67f94a5efae60fb310d8a9899e056"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit toolchain-funcs flag-o-matic cros-workon autotest

DESCRIPTION="Autotest tests"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm amd64"

IUSE="+autox +xset +tpmtools hardened"
# Enable autotest by default.
IUSE="${IUSE} +autotest"

# TODO(snanda): Remove xset dependence once power_LoadTest is switched over
# to use power manager
# TODO(semenzato): tpm-tools is included for hardware_TpmFirmware (and at this
# time only one binary is used, tpm_takeownership).  Once we have a testing
# image, a better way would be to add tpm-tools to the image.
#
# pygtk is used only in the following:
#   desktopui_ImeTest
#   desktopui_ImeLogin
# pygobject is used only in the following:
#   desktopui_ScreenLocker
#   hardware_BluetoothSemiAuto
#   network_3GActivate
#   network_3GDormancyDance
#   network_3GFailedConnect
#   network_3GRecoverFromGobiDesync
#   network_3GSafetyDance
#   network_3GSmokeTest
#   network_3GStressEnable
#   network_WiFiSmokeTest
#   network_WifiAuthenticationTests
RDEPEND="
  chromeos-base/autotest-deps
  chromeos-base/autotest-deps-glbench
  chromeos-base/autotest-deps-glmark2
  chromeos-base/autotest-deps-iotools
  chromeos-base/autotest-deps-libaio
  chromeos-base/autotest-deps-piglit
  chromeos-base/flimflam-test
  autox? ( chromeos-base/autox )
  dev-python/numpy
  dev-python/pygobject
  dev-python/pygtk
  xset? ( x11-apps/xset )
  tpmtools? ( app-crypt/tpm-tools )
"

RDEPEND="${RDEPEND}
  tests_platform_RootPartitionsNotMounted? ( sys-apps/rootdev )
  tests_platform_RootPartitionsNotMounted? ( sys-fs/udev )
  tests_test_RecallServer? ( dev-python/dnspython sys-apps/iproute2 )
"

DEPEND="${RDEPEND}"

IUSE_TESTS="
	+tests_autoupdate
	+tests_compilebench
	+tests_crashme
	+tests_dbench
	+tests_ddtest
	+tests_disktest
	+tests_fsx
	+tests_hackbench
	+tests_iperf
	+tests_bonnie
	+tests_iozone
	+tests_netperf2
	+tests_netpipe
	+tests_scrashme
	+tests_sound_infrastructure
	+tests_sleeptest
	+tests_unixbench
	+tests_audiovideo_LineOutToMicInLoopback
	+tests_audiovideo_Microphone
	+tests_audiovideo_V4L2
	+tests_cellular_Smoke
	+tests_cellular_ThroughputController
	+tests_cellular_Throughput
	+tests_build_RootFilesystemSize
	+tests_desktopui_EnterprisePolicyServer
	+tests_desktopui_FontCache
	+tests_desktopui_GTK2Config
	+tests_desktopui_ImeLogin
	+tests_desktopui_KillRestart
	+tests_desktopui_SpeechSynthesisSemiAuto
	tests_example_UnitTest
	+tests_firmware_CgptState
	+tests_firmware_CorruptBothFwBodyAB
	+tests_firmware_CorruptBothFwSigAB
	+tests_firmware_CorruptBothKernelAB
	+tests_firmware_CorruptFwBodyA
	+tests_firmware_CorruptFwBodyB
	+tests_firmware_CorruptFwSigA
	+tests_firmware_CorruptFwSigB
	+tests_firmware_CorruptKernelA
	+tests_firmware_CorruptKernelB
	+tests_firmware_DevFwNormalBoot
	+tests_firmware_DevMode
	+tests_firmware_DevScreenTimeout
	+tests_firmware_DevTriggerRecovery
	+tests_firmware_FAFTClient
	+tests_firmware_FwScreenCloseLid
	+tests_firmware_FwScreenPressPower
	+tests_firmware_InvalidUSB
	+tests_firmware_RecoveryButton
	+tests_firmware_RomSize
	+tests_firmware_TryFwB
	+tests_firmware_UserRequestRecovery
	tests_firmware_VbootCrypto
	+tests_graphics_GLBench
	+tests_graphics_GLMark2
	+tests_hardware_Ath3k
	+tests_hardware_Backlight
	+tests_hardware_ch7036
	+tests_hardware_Components
	+tests_hardware_DeveloperRecovery
	+tests_hardware_DiskSize
	+tests_hardware_EC
	+tests_hardware_EepromWriteProtect
	+tests_hardware_GobiGPS
	+tests_hardware_GPIOSwitches
	+tests_hardware_GPS
	+tests_hardware_I2CProbe
	+tests_hardware_Interrupt
	+tests_hardware_Keyboard
	+tests_hardware_LightSensor
	+tests_hardware_MemoryThroughput
	+tests_hardware_MemoryTotalSize
	+tests_hardware_MultiReader
	+tests_hardware_RealtekCardReader
	+tests_hardware_Resolution
	+tests_hardware_SAT
	+tests_hardware_SsdDetection
	+tests_hardware_StorageFio
	tests_hardware_TouchScreenPresent
	+tests_hardware_TPMCheck
	tests_hardware_TPMFirmware
	+tests_hardware_Trackpad
	+tests_hardware_VideoOutSemiAuto
	+tests_hardware_bma150
	+tests_kernel_ConfigVerify
	+tests_kernel_fs_Inplace
	+tests_kernel_fs_Punybench
	+tests_kernel_Lmbench
	+tests_kernel_LowMemNotify
	+tests_kernel_TPMPing
	+tests_kernel_HdParm
	+tests_logging_CrashSender
	+tests_logging_CrashServices
	+tests_logging_KernelCrash
	+tests_logging_KernelCrashServer
	+tests_logging_UserCrash
	+tests_login_DBusCalls
	+tests_login_SecondFactor
	+tests_network_3GActivate
	+tests_network_3GAssociation
	+tests_network_3GDisableWhileConnecting
	+tests_network_3GDisableGobiWhileConnecting
	+tests_network_3GDormancyDance
	+tests_network_3GGobiPorts
	+tests_network_3GFailedConnect
	+tests_network_3GLoadFirmware
	+tests_network_3GModemControl
	+tests_network_3GModemPresent
	+tests_network_3GNoGobi
	+tests_network_3GRecoverFromGobiDesync
	+tests_network_3GSafetyDance
	+tests_network_3GSmokeTest
	+tests_network_3GStressEnable
	+tests_network_SwitchCarrier
	+tests_network_ConnmanCromoCrash
	+tests_network_ConnmanIncludeExcludeMultiple
	+tests_network_ConnmanPowerStateTracking
	+tests_network_DhclientLeaseTestCase
	+tests_network_DisableInterface
	+tests_network_EthCaps
	+tests_network_EthCapsServer
	+tests_network_EthernetStressPlug
	+tests_network_GobiUncleanDisconnect
	+tests_network_LockedSIM
	+tests_network_ModemManagerSMS
	+tests_network_ModemManagerSMSSignal
	+tests_network_NegotiatedLANSpeed
	+tests_network_Ping
	+tests_network_Portal
	+tests_network_UdevRename
	+tests_network_WiFiCaps
	+tests_network_WiFiMatFunc
	+tests_network_WiFiPerf
	+tests_network_WiFiRoaming
	+tests_network_WiFiSecMat
	+tests_network_WiFiManager
	+tests_network_WiFiSmokeTest
	+tests_network_WifiAuthenticationTests
	+tests_network_VPN
	+tests_network_WlanHasIP
	+tests_network_netperf2
	+tests_platform_AccurateTime
	+tests_platform_AesThroughput
	+tests_platform_BootDevice
	+tests_platform_BootPerf
	+tests_platform_BootPerfServer
	+tests_platform_CheckErrorsInLog
	+tests_platform_CleanShutdown
	+tests_platform_CloseOpenLid
	+tests_platform_CloseOpenLidSimple
	+tests_platform_CrosDisksArchive
	+tests_platform_CrosDisksDBus
	+tests_platform_CrosDisksFilesystem
	+tests_platform_CrosDisksFormat
	+tests_platform_CryptohomeBadPerms
	+tests_platform_CryptohomeChangePassword
	+tests_platform_CryptohomeFio
	+tests_platform_CryptohomeMount
	+tests_platform_CryptohomeMultiple
	+tests_platform_CryptohomeNonDirs
	+tests_platform_CryptohomeStress
	+tests_platform_CryptohomeTestAuth
	+tests_platform_CryptohomeTPMReOwnServer
	+tests_platform_DaemonsRespawn
	+tests_platform_DMVerityBitCorruption
	+tests_platform_DMVerityCorruption
	+tests_platform_FileNum
	+tests_platform_FilePerms
	+tests_platform_FileSize
	+tests_platform_GCC
	+tests_platform_HighResTimers
	+tests_platform_InstallRecoveryImage
	+tests_platform_KernelErrorPaths
	+tests_platform_KernelVersion
	+tests_platform_LibCBench
	+tests_platform_LidStress
	+tests_platform_LongPressPower
	+tests_platform_MemCheck
	+tests_platform_NetParms
	+tests_platform_OSLimits
	+tests_platform_PartitionCheck
	+tests_platform_Pkcs11InitUnderErrors
	+tests_platform_Pkcs11ChangeAuthData
	+tests_platform_Pkcs11Events
	+tests_platform_Pkcs11LoadPerf
	+tests_platform_Rootdev
	+tests_platform_RootPartitionsNotMounted
	+tests_platform_ServoPyAuto
	+tests_platform_SessionManagerTerm
	+tests_platform_Shutdown
	+tests_platform_SuspendStress
	+tests_platform_TempFS
	+tests_platform_ToolchainOptions
	+tests_power_ARMSettings
	+tests_power_Backlight
	+tests_power_BatteryCharge
	+tests_power_Consumption
	+tests_power_CPUFreq
	+tests_power_CPUIdle
	+tests_power_Draw
	+tests_power_ProbeDriver
	+tests_power_Resume
	+tests_power_Standby
	+tests_power_StatsCPUFreq
	+tests_power_StatsCPUIdle
	+tests_power_StatsUSB
	+tests_power_Status
	+tests_power_SuspendResume
	+tests_power_x86Settings
	+tests_realtimecomm_GTalkAudioBench
	+tests_realtimecomm_GTalkLmiCamera
	+tests_realtimecomm_GTalkunittest
	+tests_security_AccountsBaseline
	+tests_security_ASLR
	+tests_security_ChromiumOSLSM
	+tests_security_DbusMap
	+tests_security_DbusOwners
	+tests_security_HardlinkRestrictions
	+tests_security_HciconfigDefaultSettings
	+tests_security_HtpdateHTTP
	+tests_security_Minijail_seccomp
	+tests_security_Minijail0
	+tests_security_OpenFDs
	+tests_security_OpenSSLBlacklist
	+tests_security_OpenSSLRegressions
	+tests_security_ptraceRestrictions
	+tests_security_ReservedPrivileges
	+tests_security_RestartJob
	+tests_security_RootCA
	+tests_security_RootfsOwners
	+tests_security_RootfsStatefulSymlinks
	+tests_security_SandboxedServices
	+tests_security_SeccompSyscallFilters
	+tests_security_SuidBinaries
	+tests_security_SymlinkRestrictions
	+tests_suites
	+tests_suite_HWConfig
	+tests_suite_HWQual
	+tests_test_Recall
	+tests_test_RecallServer
"

IUSE="${IUSE} ${IUSE_TESTS}"

CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

AUTOTEST_DEPS_LIST=""
AUTOTEST_CONFIG_LIST=""
AUTOTEST_PROFILERS_LIST=""

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
