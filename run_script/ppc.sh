#!/bin/bash

qemu-system-ppc \
    -m 512 \
    -machine mac99 \
    -cpu g4 \
    -kernel vmlinux \
    -hda rootfs.qcow2 \
    -append "rootwait root=/dev/sda quiet" \
    -net nic,model=sungem \
    -net user,hostfwd=tcp::20022-:22,hostfwd=tcp::28888-:8888,hostfwd=tcp::29999-:9999 \
    -nographic
