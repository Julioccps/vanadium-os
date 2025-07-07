#!/bin/bash

set -e

nasm -f bin boot.s -o bootloader.bin
nasm -f bin kernel.s -o kernel.bin

dd if=/dev/zero of=disk.img bs=512 count=2880
dd if=bootloader.bin of=disk.img conv=notrunc
dd if=kernel.bin of=disk.img bs=512 seek=1 conv=notrunc

echo "Build Complete, run with"
echo "qemu-system-i386 -fda disk.img -display sdl"
