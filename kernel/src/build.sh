#!/bin/bash

set -euxo pipefail

SCRIPT_DIR=$(dirname "$0")

export KERNEL=kernel8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-
make CC="ccache aarch64-linux-gnu-gcc" bcm2711_defconfig -j $(nproc)
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- LSMOD=${SCRIPT_DIR}/minimal-lsmod.txt localmodconfig
./scripts/kconfig/merge_config.sh .config ${SCRIPT_DIR}/bsli-kernel.config
make CC="ccache aarch64-linux-gnu-gcc" Image modules dtbs -j $(nproc)
