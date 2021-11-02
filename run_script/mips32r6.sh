#!/bin/bash

qemu-system-mips \
    -m 512 \
    -machine malta \
    -cpu mips32r6-generic \
    -kernel vmlinux \
    -hda rootfs.qcow2 \
    -append "rootwait root=/dev/hda console=ttyS0 quiet" \
    -net nic,model=pcnet \
    -net user,hostfwd=tcp::20022-:22,hostfwd=tcp::28888-:8888,hostfwd=tcp::29999-:9999 \
    -nographic
