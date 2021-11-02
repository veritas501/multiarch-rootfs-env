#!/bin/bash

qemu-system-s390x \
    -m 512 \
    -machine s390-ccw-virtio \
    -cpu max,zpci=on \
    -kernel bzImage \
    -hda rootfs.qcow2 \
    -append "rootwait root=/dev/vda net.ifnames=0 biosdevname=0 quiet" \
    -net nic,model=virtio \
    -net user,hostfwd=tcp::20022-:22,hostfwd=tcp::28888-:8888,hostfwd=tcp::29999-:9999 \
    -nographic
