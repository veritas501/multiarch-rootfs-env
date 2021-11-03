#!/bin/bash

qemu-system-i386 \
    -m 512 \
    -machine pc \
    -kernel bzImage \
    -hda rootfs.qcow2 \
    -append "rootwait root=/dev/sda console=tty1 console=ttyS0" \
    -net nic,model=virtio \
    -net user,hostfwd=tcp::20022-:22,hostfwd=tcp::28888-:8888,hostfwd=tcp::29999-:9999 \
    -nographic

