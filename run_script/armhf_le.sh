#!/bin/bash

qemu-system-arm \
    -m 512 \
    -machine vexpress-a9 \
    -kernel zImage \
    -dtb vexpress-v2p-ca9.dtb \
    -drive file=rootfs.qcow2,if=sd \
    -append "rootwait root=/dev/mmcblk0 console=ttyAMA0,115200 quiet" \
    -net nic,model=lan9118 \
    -net user,hostfwd=tcp::20022-:22,hostfwd=tcp::28888-:8888,hostfwd=tcp::29999-:9999 \
    -nographic
