#!/bin/bash

MAIN_PWD=$(dirname $(readlink -f $0))

BUILDROOT_VERSION="2021.08.1"
BUILDROOT_URL="https://buildroot.org/downloads/buildroot-${BUILDROOT_VERSION}.tar.gz"
BUILDROOT_DIR="buildroot"
BUILDROOT_TARBALL="buildroot.tar.gz"

declare -A BUILD_TARGET
BUILD_TARGET=(
    ["aarch64_le"]="qemu_aarch64_virt_defconfig"
    ["armhf_le"]="qemu_arm_vexpress_defconfig"
    ["mips32r2"]="qemu_mips32r2_malta_defconfig"
    ["mips32r2el"]="qemu_mips32r2el_malta_defconfig"
    ["mips32r6"]="qemu_mips32r6_malta_defconfig"
    ["mips32r6el"]="qemu_mips32r6el_malta_defconfig"
    ["mips64"]="qemu_mips64_malta_defconfig"
    ["mips64el"]="qemu_mips64el_malta_defconfig"
    ["mips64r6"]="qemu_mips64r6_malta_defconfig"
    ["mips64r6el"]="qemu_mips64r6el_malta_defconfig"
    ["ppc"]="qemu_ppc_mac99_defconfig"
    ["ppc64"]="qemu_ppc64_pseries_defconfig"
    ["ppc64_le"]="qemu_ppc64le_pseries_defconfig"
    ["riscv32"]="qemu_riscv32_virt_defconfig"
    ["riscv64"]="qemu_riscv64_virt_defconfig"
    ["s390x"]="qemu_s390x_defconfig"
    ["x86"]="qemu_x86_defconfig"
    ["x86_64"]="qemu_x86_64_defconfig"
)

wget_fail_clean(){
    echo "[-] wget failed"
    rm -rf "$BUILDROOT_TARBALL"
    exit 1
}

# download buildroot and extract
get_buildroot()
{
    pushd "${MAIN_PWD}"
    if [ ! -f "$BUILDROOT_TARBALL" ]; then
        wget "$BUILDROOT_URL" -O "$BUILDROOT_TARBALL"  || wget_fail_clean
    fi
    if [ -d "$BUILDROOT_DIR" ]; then
        rm -rf "$BUILDROOT_DIR"
    fi
    mkdir -p "$BUILDROOT_DIR"
    tar xf "$BUILDROOT_TARBALL" -C "$BUILDROOT_DIR" --strip-components=1
    popd
}

post_gen_config()
{
    if [[ $target == "riscv32" ||  $target == "riscv64" ]]; then
	./support/kconfig/merge_config.sh .config "${MAIN_PWD}/assets/riscv_config_fragment" || exit 1
    fi
    if [[ $target == "x86" ||  $target == "x86_64" ]]; then
        ./support/kconfig/merge_config.sh .config "${MAIN_PWD}/assets/x86_config_fragment" || exit 1
    fi
}

# generate .config
gen_config()
{
    pushd "${MAIN_PWD}/${BUILDROOT_DIR}"
    make "$build_target" || exit 1
    ./support/kconfig/merge_config.sh .config "${MAIN_PWD}/assets/common_config_fragment" || exit 1
    post_gen_config
    popd
}

run_buildroot()
{
    pushd "${MAIN_PWD}/${BUILDROOT_DIR}"
    make || exit 1
    popd
}

pre_get_result()
{
    if [ $target == "ppc" ]; then
        cp "${MAIN_PWD}/assets/openbios-ppc" "openbios-ppc"
    fi
}

get_build_result()
{
    pushd "${MAIN_PWD}/${BUILDROOT_DIR}/output/images"
    pre_get_result
    [ -f rootfs.ext3 ] || (echo "[-] Can't found rootfs.ext3"; exit 1)
    qemu-img convert -f raw -O qcow2 rootfs.ext3 rootfs.qcow2 || exit 1
    rm -f *.sh *.ext*
    cp "${MAIN_PWD}/assets/boot_scripts/${target}.sh" "run.sh"
    tar czf "${target}.tar.gz" *
    mv "${target}.tar.gz" "${MAIN_PWD}"
    if [ ! -f "${MAIN_PWD}/${target}.tar.gz" ]; then
        echo "[-] Oops, build result not found"
    else
        echo "[+] Build result is at ${MAIN_PWD}/${target}.tar.gz"
    fi
    popd
}

# print help information
help()
{
    echo "usage: start_build.sh <build_target>"
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
