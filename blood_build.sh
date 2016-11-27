#!/bin/bash

kerneldir=$(pwd)
outdir=$kerneldir/out
zipoutdir=$outdir/zip
kerneloutdir=$outdir/obj/KERNEL_OBJ
toolchainpath=$kerneldir/toolchain/UBERTC/aarch64-linux-android-4.9-kernel/bin/aarch64-linux-android-
date=$(date +%F-%H-%M)
brand='MEIZU'
device='M2 Note'
model='m2note'
arch='arm64'
defconfig='blood_m2note_defconfig'
kernelver='3.18.10'
bloodver=$kernelver.r2.0_CCC-Design
akscripts=$kerneldir/anykernel_blood
zipname=blood_kernel-$bloodver-$model-$date.zip
cputhreads=$(cat /proc/cpuinfo | grep processor | wc -l)

echo '======================================================================'
echo ' '
echo ' '
echo ' '
echo ' '
echo '                          Kernel parameters:                          '
echo ' '
echo ' ZIP name: '$zipname' '
echo ' Brand: '$brand' '
echo ' Device: '$device' '
echo ' Model: '$model' '
echo ' Defconfig: '$defconfig' '
echo ' Linux kernel version: '$kernelver' '
echo ' Blood kernel version: '$bloodver' '
echo ' Build date: '$date' '
echo ' Host CPU threads: '$cputhreads' '
echo ' '
echo ' '
echo ' '
echo ' Toolchain path= '$toolchainpath' '
echo ' '
echo ' '
echo ' '
echo ' '
echo '======================================================================'

echo 'Cleaning up directory...'
if [ -d $outdir ]
then
    rm -r $outdir
fi

echo 'Setting variables...'
export ARCH=$arch
export SUBARCH=$arch
export CROSS_COMPILE=$toolchainpath
export CONFIG=$defconfig
export KERNEL=$kerneldir
export OUT=$outdir
export ZIPOUT=$zipoutdir
export KERNELOUT=$kerneloutdir
STRIP=${CROSS_COMPILE}strip

echo 'Building kernel...'
mkdir -p $KERNELOUT
mkdir -p $ZIPOUT
mkdir -p $KERNELOUT/tmp/kernel
mkdir -p $KERNELOUT/tmp/system/lib/modules
make O=$KERNELOUT $CONFIG
make -j$cputhreads O=$KERNELOUT | tee $OUT/build-$model-$date.log

if [ -f $KERNELOUT/arch/arm64/boot/Image.gz-dtb ]
then
    cp -f $KERNELOUT/arch/arm64/boot/Image.gz-dtb $OUT/zImage
fi

echo 'Kernel building succesful!'

echo 'Creating ZIP...'
cp -r $akscripts/* $ZIPOUT/
cp -f $OUT/zImage $ZIPOUT/zImage
cd $ZIPOUT
zip -q -r -D -X $zipname ./*

echo 'Cleaning after building...'
mv $zipname $OUT/$zipname
cd $OUT

if [ -f zImage ]
then
    rm -r zImage
fi

if [ -d obj ]
then
    rm -r obj
fi

if [ -d $ZIPOUT ]
then
    rm -r $ZIPOUT
fi

cd $kerneldir
