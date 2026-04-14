# Headwolf F8 Suspend Fix (APatch Module)

APatch module (v2.0) that loads `kpm_fix.ko` at boot to prevent **sleep-time WDT reboots** and **SD card tuning failures** on the Headwolf F8 tablet (MT8792 / Dimensity 8300).

## Problems

1. **WDT reboot during sleep** — The mt6375 PMIC auxadc driver fails `imix_r` calibration during late suspend, returning `-EIO`. This aborts the suspend cycle and causes rapid suspend/resume cycling that exhausts the hardware watchdog timer, triggering a forced reboot.
2. **SD card CMD19 CRC error on resume** — After suspend/resume, MSDC controller PAD timing drifts. `msdc_execute_tuning()` sends CMD19 but receives CRC errors, triggering card reset and speed downgrade.

## Solution

The kernel module (`kpm_fix.ko`) installs two kretprobes:
- **`mt6375_auxadc_suspend_late`** — Overrides negative returns to `0`, allowing suspend to proceed
- **`msdc_execute_tuning`** — Overrides tuning failure returns to `0`, preserving valid PAD_TUNE values

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
