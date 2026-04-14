# Headwolf F8 Suspend Fix (APatch Module)

APatch module (v1.0) that loads `kpm_fix.ko` at boot to prevent **sleep-time WDT reboots** on the Headwolf F8 tablet (MT8792 / Dimensity 8300).

## Problem

The mt6375 PMIC auxadc driver fails `imix_r` calibration during late suspend, returning `-EIO`. This aborts the suspend cycle and causes rapid suspend/resume cycling that exhausts the hardware watchdog timer, triggering a forced reboot while the device is asleep.

## Solution

The kernel module (`kpm_fix.ko`) installs a kretprobe on `mt6375_auxadc_suspend_late` that replaces negative return values with `0`, allowing the suspend sequence to complete normally. The calibration still runs — only the error propagation is suppressed.

See [Headwolf_F8_KPM_Fix_Kernel](https://github.com/zerofrip/Headwolf_F8_KPM_Fix_Kernel) for technical details.

## Install

1. Download `KPM_Fix_Module.zip` from [Releases](https://github.com/zerofrip/Headwolf_F8_KPM_Fix_APatch/releases)
2. Open APatch → Module Manager → Install from storage
3. Select `KPM_Fix_Module.zip`
4. Reboot

## Structure

```text
├── module.prop       # APatch module metadata (id: f8_kpm_fix)
├── customize.sh      # Install script
├── service.sh        # Boot-time service (insmod kpm_fix.ko)
├── kpm_fix.ko        # Compiled kernel module
├── pack.sh           # Package builder (creates KPM_Fix_Module.zip)
└── update.json       # Version info for auto-update
```

## Boot Flow (`service.sh`)

1. Check if `kpm_fix.ko` exists in module directory
2. Skip if already loaded (`/proc/modules`)
3. `insmod kpm_fix.ko`
4. Log result via `log -t KPM_FIX`

## Compatibility

| Item | Value |
|------|-------|
| Device | Headwolf F8 |
| SoC | MT8792 (Dimensity 8300 / MT6897) |
| Kernel | 6.1 GKI |
| Root | APatch / KernelSU |
| PMIC | mt6375 |

## License

GPL-2.0
