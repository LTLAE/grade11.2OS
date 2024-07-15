echo "Building..."
nasm -I include/ -o 3.2.2.MBR.bin 3.2.2.MBR.S   
nasm -I include/ -o 3.2.2.loader.bin 3.2.2.loader.S
echo "Building Done."
echo "Writing..."
dd if=3.2.2.MBR.bin of=hd60M.img bs=512 count=1 conv=notrunc
dd if=3.2.2.loader.bin of=hd60M.img bs=512 count=1 seek=2 conv=notrunc
echo "Writing Done."
bochs -f yjybochsrc.disk