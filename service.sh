#!/system/bin/sh
# Headwolf F8 Suspend Fix — Service Script
# Loads kpm_fix.ko to suppress mt6375 auxadc suspend failures.

MODDIR="${0%/*}"
MODULE_ID="f8_kpm_fix"

logi() {
    log -t "KPM_FIX" "$1"
}

# ─── Load kernel module ──────────────────────────────────────────────────
KO_PATH="${MODDIR}/kpm_fix.ko"

if [ ! -f "${KO_PATH}" ]; then
    logi "ERROR: kpm_fix.ko not found at ${KO_PATH}"
    exit 1
fi

# Check if already loaded
if grep -q "^kpm_fix " /proc/modules 2>/dev/null; then
    logi "kpm_fix already loaded, skipping"
    exit 0
fi

insmod "${KO_PATH}"
ret=$?

if [ ${ret} -eq 0 ]; then
    logi "kpm_fix.ko loaded successfully"
else
    logi "ERROR: insmod failed with code ${ret}"
fi
