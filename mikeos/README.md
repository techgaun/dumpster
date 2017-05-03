nasm -f bin -o os.bin os.asm


dd status=noxfer conv=notrunc if=os.bin of=mikeos.flp


qemu-system-i386 -fda mikeos.flp
