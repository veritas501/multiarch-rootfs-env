#!/bin/bash

qemu-system-aarch64 \
    -m 512 \
    -machine virt \
    -cpu cortex-a53 \
    -kernel Image \
    -drive file=rootfs.qcow2,if=none,id=hd0 \
    -device virtio-blk-device,drive=hd0 \
    -append "rootwait root=/dev/vda console=ttyAMA0 quiet" \
    -net nic \
    -net user,hostfwd=tcp::20022-:22,hostfwd=tcp::28888-:8888,hostfwd=tcp::29999-:9999 \
    -nographic
