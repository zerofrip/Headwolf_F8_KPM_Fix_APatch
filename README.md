# Headwolf F8 Suspend Fix (APatch Module)

APatch module (v3.0) that loads `kpm_fix.ko` at boot to prevent **sleep-time WDT reboots** on the Headwolf F8 tablet (MT6897 / Dimensity 8300).

## Problem

**WDT reboot during sleep** — The mt6375 PMIC auxadc driver fails `imix_r` calibration during late suspend, returning `-EIO`. This aborts the suspend cycle and causes rapid suspend/resume cycling (~every 2 minutes) that exhausts the hardware watchdog timer, triggering a forced reboot.

## Solution

The kernel module (`kpm_fix.ko`) installs a kretprobe on **`__device_suspend_late`** (a kernel PM framework function). When the mt6375 auxadc device is suspended and returns an error, the return value is overridden to `0`, allowing the suspend sequence to proceed normally.

> **Why not hook `mt6375_auxadc_suspend_late` directly?**
> GKI 6.1 uses `KPROBES_ON_FTRACE`, which requires ftrace entry points. Vendor modules lack these, so a direct kretprobe registers but never fires. Hooking the kernel-internal `__device_suspend_late` bypasses this limitation.

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
| SoC | MT6897 (Dimensity 8300) |
| Kernel | 6.1 GKI |
| Root | APatch / KernelSU |
| PMIC | mt6375 |

## License

GPL-2.0
