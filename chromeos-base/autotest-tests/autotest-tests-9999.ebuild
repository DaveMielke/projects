# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit toolchain-funcs flag-o-matic libchrome cros-debug cros-workon autotest

DESCRIPTION="Autotest tests"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~*"
IUSE="arc-camera3 -chromeless_tests -chromeless_tty +crash_reporting cups +encrypted_stateful hammerd +network_time -ppp +passive_metrics +profile vaapi"
# Enable autotest by default.
IUSE="${IUSE} +autotest"

# pygobject is used in the following tests:
#   firmware_TouchMTB
#   platform_CrosDisks*
RDEPEND="
	>=chromeos-base/autotest-deps-0.0.3
	!<=chromeos-base/autotest-factory-0.0.1-r4445
	dev-python/numpy
	dev-python/pygobject
	dev-python/pytest
	dev-python/python-uinput
	media-sound/sox
	sys-apps/ethtool
	vaapi? ( x11-libs/libva )
	virtual/autotest-tests
"

RDEPEND="${RDEPEND}
	tests_dbench? ( dev-libs/libaio )
	tests_platform_MetricsUploader? (
		chromeos-base/metrics
		dev-python/protobuf-python
	)
	tests_platform_SecureEraseFile? ( chromeos-base/secure-erase-file )
	tests_hardware_MemoryLatency? ( app-benchmarks/lmbench )
	tests_hardware_MemoryThroughput? ( app-benchmarks/lmbench )
	tests_hardware_MemoryZRAMThroughput? ( app-benchmarks/microbenchmarks )
	tests_kernel_Lmbench? ( app-benchmarks/lmbench )
	tests_security_SMMLocked? ( sys-apps/pciutils )
	arc-camera3? (
		tests_camera_HAL3? ( chromeos-base/autotest-deps-camera-hal3 )
		tests_camera_HAL3Perf? ( chromeos-base/autotest-deps-camera-hal3 )
	)
	tests_camera_V4L2? ( media-libs/libyuv dev-libs/re2 )
	tests_xfsFilesystemTestSuite? ( app-benchmarks/xfstests )
"

DEPEND="${RDEPEND}"

X86_IUSE_TESTS="
	+tests_security_SMMLocked
	+tests_xfsFilesystemTestSuite
"

CLIENT_IUSE_TESTS="
	x86? ( ${X86_IUSE_TESTS} )
	amd64? ( ${X86_IUSE_TESTS} )
	+tests_profiler_sync
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
	+tests_netpipe
	+tests_sleeptest
	+tests_kernel_sysrq_info
	+tests_unixbench
	+tests_autoupdate_Backoff
	+tests_autoupdate_BadMetadata
	+tests_autoupdate_CannedOmahaUpdate
	+tests_autoupdate_DisconnectReconnectNetwork
	+tests_autoupdate_UrlSwitch
	+tests_blktestsSuiteAll
	+tests_blktestsSuiteLoopOverBlk
	+tests_blktestsSuiteLoopOverFile
	+tests_blktestsSuiteRealBlk
	+tests_camera_V4L2
	arc-camera3? (
		+tests_camera_HAL3
		+tests_camera_HAL3Perf
	)
	!chromeless_tty? (
		!chromeless_tests? (
			+tests_desktopui_CrashyReboot
			+tests_desktopui_FontCache
			+tests_desktopui_HangDetector
			+tests_desktopui_SpeechSynthesisSemiAuto
		)
	)
	hammerd? (
		+tests_detachablebase_TriggerHammerd
	)
	+tests_dummy_Fail
	+tests_dummy_Pass
	tests_example_UnitTest
	+tests_firmware_RomSize
	+tests_firmware_SetFWMP
	+tests_firmware_TouchMTB
	+tests_firmware_VbootCrypto
	+tests_flaky_test
	+tests_hardware_Badblocks
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
	+tests_hardware_MemoryLatency
	+tests_hardware_MemoryThroughput
	+tests_hardware_MemoryZRAMThroughput
	+tests_hardware_Memtester
	+tests_hardware_MultiReader
	+tests_hardware_ProbeComponents
	+tests_hardware_RamFio
	+tests_hardware_RealtekCardReader
	+tests_hardware_Resolution
	+tests_hardware_SAT
	+tests_hardware_Smartctl
	+tests_hardware_SsdDetection
	+tests_hardware_StorageFio
	+tests_hardware_StorageTrim
	+tests_hardware_StorageWearoutDetect
	+tests_hardware_TouchScreenPowerCycles
	tests_hardware_TouchScreenPresent
	+tests_hardware_TrimIntegrity
	+tests_infra_FirmwareAutoupdate
	+tests_kernel_AsyncDriverProbe
	+tests_kernel_FirmwareRequest
	+tests_kernel_CheckArmErrata
	ppp? ( +tests_kernel_ConfigVerifyPPP )
	+tests_kernel_CpufreqMinMax
	+tests_kernel_CrosECSysfs
	+tests_kernel_CrosECSysfsAccel
	+tests_kernel_CryptoAPI
	+tests_kernel_Delay
	+tests_kernel_fs_Inplace
	+tests_kernel_fs_Punybench
	+tests_kernel_HdParm
	+tests_kernel_IgnoreGptOptionServer
	+tests_kernel_Ktime
	+tests_kernel_Lmbench
	+tests_kernel_LowMemNotify
	+tests_kernel_Memory_Ramoop
	profile? ( +tests_kernel_PerfEventRename )
	+tests_kernel_SchedBandwith
	+tests_kernel_VbootContextEC
	crash_reporting? (
		+tests_logging_CrashSender
		+tests_logging_KernelCrash
		+tests_logging_UdevCrash
		+tests_logging_UserCrash
		+tests_platform_AnomalyDetector
	)
	+tests_network_EthCaps
	+tests_network_EthernetStressPlug
	+tests_network_Ipv6SimpleNegotiation
	+tests_network_NegotiatedLANSpeed
	+tests_network_UdevRename
	+tests_network_WiFiCaps
	+tests_platform_AccurateTime
	+tests_platform_AesThroughput
	!chromeless_tty? (
		+tests_platform_BootPerf
	)
	+tests_platform_CheckErrorsInLog
	+tests_platform_CleanShutdown
	+tests_platform_CompressedSwap
	+tests_platform_CompressedSwapPerf
	+tests_platform_Crossystem
	+tests_platform_Crouton
	+tests_platform_DaemonsRespawn
	+tests_platform_DBusMachineIdRotation
	+tests_platform_DMVerityBitCorruption
	+tests_platform_DMVerityCorruption
	encrypted_stateful? ( +tests_platform_EncryptedStateful )
	+tests_platform_ExternalUSBBootStress
	+tests_platform_ExternalUSBStress
	+tests_platform_FileNum
	+tests_platform_FileSize
	+tests_platform_Firewall
	+tests_platform_FullyChargedPowerStatus
	+tests_platform_HighResTimers
	+tests_platform_ImageLoader
	+tests_platform_ImageLoaderServer
	+tests_platform_KernelVersion
	+tests_platform_KernelVersionByBoard
	+tests_platform_LibCBench
	+tests_platform_LogDupSuppression
	+tests_platform_LogNonKernelKmsg
	+tests_platform_MemCheck
	+tests_platform_MemoryMonitor
	chromeless_tty? ( +tests_platform_MetricsUploader )
	+tests_platform_NetParms
	+tests_platform_OpenSSLActual
	profile? (
		+tests_platform_Perf
		+tests_platform_Quipper
	)
	cups? ( +tests_platform_PrinterPpds )
	+tests_platform_Rootdev
	+tests_platform_SecureEraseFile
	!chromeless_tty? ( +tests_platform_SessionManagerStateKeyGeneration )
	+tests_platform_TabletMode
	+tests_platform_TempFS
	network_time? (
		+tests_platform_TLSDate
		+tests_platform_TLSDateActual
	)
	+tests_platform_ToolchainOptions
	+tests_platform_UdevVars
	+tests_suite_HWConfig
	+tests_suite_HWQual
	+tests_system_ColdBoot
	+tests_touch_HasInput
	+tests_touch_UpdateErrors
	+tests_touch_WakeupSource
	+tests_usbpd_DisplayPortSink
	+tests_vpd_ReadWrite
"

IUSE_TESTS="${IUSE_TESTS}
	${CLIENT_IUSE_TESTS}
"

IUSE="${IUSE} ${IUSE_TESTS}"

CROS_WORKON_LOCALNAME=../third_party/autotest/files

AUTOTEST_DEPS_LIST=""
AUTOTEST_CONFIG_LIST=""
AUTOTEST_PROFILERS_LIST=""

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
