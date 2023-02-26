#!/bin/bash -
#===============================================================================
#
#          FILE: rc-kernel-pull-build-boot.sh
#
#         USAGE: ./rc-kernel-pull-build-boot.sh
#
#   DESCRIPTION: This is automated script to check RC kernel ,build, compile,boot
#
#       OPTIONS: ---
#  REQUIREMENTS: qemu
#          BUGS: ---
#         NOTES: mutt integration for sending mail of the result
#        AUTHOR: Bhaskar Chowdhury (https://about.me/unixbhaskar), unixbhaskar@gmail.com
#  ORGANIZATION: Independent
#       CREATED: 03/17/2020 15:42
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

ker_source="/home/bhaskar/git-linux/linux"
qemu=$(command -v qemu-system-x86_64)
bzimage="$ker_source/arch/x86/boot/bzImage"
rootfs="/home/bhaskar/git-linux/buildroot/output/images/rootfs.ext4.xz"
#dracut=$(command -v dracut)
#initrd="$ker_source/initrd-rootfile.img"

build_kernel_and_boot_with_qemu(){

	make clean && make mrproper
        zcat /proc/config.gz > .config
	make olddefconfig
	make V=1 ARCH=x86_64 -j$(getconf _NPROCESSORS_ONLN) LOCALVERSION=-$(hostname) | tee kernel_build.log
	make modules
	$qemu -boot c -m 2049M -kernel $bzimage  -hda $rootfs -nographic -append "root=/dev/sda rw console=ttyS0"
        return 0
}

#boot_with_initrd(){

#	$dracut -l -o $initrd
#	$qemu -boot c -m 2049M -kernel $bzimage -initrd $initrd  -hda $rootfs -nographic -append "root=/dev/sda rw console=ttyS0"
#        return 0
#}


mainline_kernel=$(curl -s https://www.kernel.org/ | grep -A1 'mainline:' | grep -oP '(?<=strong>).*(?=</strong.*)')
     /usr/bin/notify-send --expire-time=5000 "New RC kernel available:" $mainline_kernel

if [[ "$mainline_kernel" != "" ]];then
	echo "We have new RC kernel"
        cd $ker_source && git pull
	if [[ $? != 0 ]];then
		echo "Pull again!.."
		git pull
	else
		echo "We are fine ..pls proceed.."
	fi
        build_kernel_and_boot_with_qemu
else
	echo "We do not have new RC kernel"
	exit 1
fi



