#!/bin/bash

qemu-system-ppc64 \
    -m 512 \
    -machine pseries \
    -cpu POWER8 \
    -kernel vmlinux \
    -drive file=rootfs.qcow2,if=scsi,index=0 \
    -append "rootwait root=/dev/sda console=hvc0 quiet" \
    -net nic \
    -net user,hostfwd=tcp::20022-:22,hostfwd=tcp::28888-:8888,hostfwd=tcp::29999-:9999 \
    -nographic
