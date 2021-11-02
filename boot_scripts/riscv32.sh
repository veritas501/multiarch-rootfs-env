#!/bin/bash

qemu-system-riscv32 \
    -m 512 \
    -machine virt \
    -bios fw_jump.elf \
    -kernel Image \
    -drive file=rootfs.qcow2,id=hd0 \
    -device virtio-blk-device,drive=hd0 \
    -append "rootwait root=/dev/vda console=ttyS0 quiet" \
    -netdev user,id=net0,hostfwd=tcp::20022-:22,hostfwd=tcp::28888-:8888,hostfwd=tcp::29999-:9999 \
    -device virtio-net-device,netdev=net0 \
    -nographic
