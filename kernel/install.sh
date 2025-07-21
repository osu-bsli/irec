#!/bin/sh

set -euxo pipefail

KERNEL_OUTDIR=$1

export KERNEL=kernel8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- 
rm -rfv ${KERNEL_OUTDIR}
mkdir -p ${KERNEL_OUTDIR}/boot/firmware/overlays   
cp arch/arm64/boot/Image               ${KERNEL_OUTDIR}/boot/firmware/kernel8-bsli.img
cp arch/arm64/boot/dts/broadcom/*.dtb  ${KERNEL_OUTDIR}/boot/firmware/
cp arch/arm64/boot/dts/overlays/*.dtb* ${KERNEL_OUTDIR}/boot/firmware/overlays/
cp arch/arm64/boot/dts/overlays/README ${KERNEL_OUTDIR}/boot/firmware/overlays/
make -j12 INSTALL_MOD_PATH=${KERNEL_OUTDIR} modules_install

