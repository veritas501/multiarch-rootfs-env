#!/bin/bash

MAIN_PWD="$PWD"

BUILDROOT_VERSION="2021.08.1"
BUILDROOT_URL="https://buildroot.org/downloads/buildroot-${BUILDROOT_VERSION}.tar.gz"
BUILDROOT_DIR="buildroot"
BUILDROOT_TARBALL="buildroot.tar.gz"

declare -A BUILD_TARGET
BUILD_TARGET=(
    ["aarch64_le"]="qemu_aarch64_virt_defconfig"
    ["armhf_le"]="qemu_arm_vexpress_defconfig"
)

# download buildroot and extract
get_buildroot()
{
    pushd "${MAIN_PWD}"
    if [ ! -f "$BUILDROOT_TARBALL" ]; then
        wget "$BUILDROOT_URL" -O "$BUILDROOT_TARBALL"
    fi
    mkdir -p "$BUILDROOT_DIR"
    tar xf "$BUILDROOT_TARBALL" -C "$BUILDROOT_DIR" --strip-components=1
    popd
}

# generate .config
gen_config()
{
    pushd "${MAIN_PWD}/${BUILDROOT_DIR}"
    make "$build_target" || exit 1
    ./support/kconfig/merge_config.sh .config "${MAIN_PWD}/config_fragment" || exit 1
    popd
}

run_buildroot()
{
    pushd "${MAIN_PWD}/${BUILDROOT_DIR}"
    make || exit 1
    popd
}

get_build_result()
{
    pushd "${MAIN_PWD}/${BUILDROOT_DIR}/output/images"
    [ -f rootfs.ext3 ] || (echo "[-] Can't found rootfs.ext3"; exit 1)
    qemu-img convert -f raw -O qcow2 rootfs.ext3 rootfs.qcow2 || exit 1
    rm -f *.sh *.ext*
    cp "${MAIN_PWD}/run_script/${target}.sh" "run.sh"
    tar czf "${target}.tar.gz" *
    mv "${target}.tar.gz" "${MAIN_PWD}"
    popd
}

# print help information
help()
{
    echo "usage: auto_build.sh <build_target>"
    echo ""
    echo "build_targets: (le: little_endian, be: big_endian)"
    for k in ${!BUILD_TARGET[@]}; do
        echo "* ${k}"
    done
}

# ------------- main -------------
if [ $# -le 0 ]; then
    help
    exit
fi

target=$1
if [[ $target == "-h" || $target == "--help" ]]; then
    help
    exit
fi
build_target=${BUILD_TARGET[$target]}
if [ ! $build_target ]; then
    echo "[-] $target is not available"
    help
    exit 
fi

echo "[*] Use defconfig: $build_target"

# ------------- main logic -------------
set -x 
get_buildroot
gen_config
run_buildroot
get_build_result
