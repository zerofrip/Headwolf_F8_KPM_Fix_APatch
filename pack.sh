#!/usr/bin/env bash
# pack.sh — Package KPM_Fix APatch module into KPM_Fix_Module.zip
#
# Usage (from Headwolf_F8_KPM_Fix_APatch/):
#   ./pack.sh [KERNEL_DIR=<path>] [OUT=<path/to/KPM_Fix_Module.zip>]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KERNEL_DIR="${KERNEL_DIR:-}"
OUT="${OUT:-}"

for arg in "$@"; do
    case "$arg" in
        KERNEL_DIR=*) KERNEL_DIR="${arg#KERNEL_DIR=}" ;;
        OUT=*)        OUT="${arg#OUT=}" ;;
        *) echo "WARNING: Unknown argument: $arg" ;;
    esac
done

if [[ -z "$KERNEL_DIR" ]]; then
    KERNEL_DIR="$(cd "${SCRIPT_DIR}/../Headwolf_F8_KPM_Fix_Kernel" 2>/dev/null && pwd || echo "")"
fi
if [[ -z "$OUT" ]]; then
    OUT="${SCRIPT_DIR}/KPM_Fix_Module.zip"
fi

if [[ ! -d "$KERNEL_DIR" ]]; then
    echo "ERROR: Kernel directory not found: '$KERNEL_DIR'"
    exit 1
fi

KO_SRC="${KERNEL_DIR}/kpm_fix.ko"
if [[ ! -f "$KO_SRC" ]]; then
    echo "ERROR: kpm_fix.ko not found in '$KERNEL_DIR'. Run build.sh first."
    exit 1
fi

echo "Copying kpm_fix.ko from kernel dir..."
cp -v "$KO_SRC" "${SCRIPT_DIR}/kpm_fix.ko"

echo "Creating ${OUT}..."
cd "$SCRIPT_DIR"
rm -f "$OUT"

zip -9 "$OUT" \
    module.prop \
    customize.sh \
    service.sh \
    kpm_fix.ko

echo ""
echo "Package created:"
ls -lh "$OUT"
echo "Contents:"
unzip -l "$OUT"
