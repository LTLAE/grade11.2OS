alias i386gcc='i386-elf-gcc'
alias i386g++='i386-elf-g++'
alias i386ld='i386-elf-ld'

# echo "Clearing build folder"
# rm -rf program/build/*

echo "Compiling..."
# nasm -I program/boot/include/ -o program/build/MBR.bin program/boot/MBR.S   
# nasm -I program/boot/include/ -o program/build/loader.bin program/boot/loader.S
i386gcc -I program/lib/ -I program/kernel/ -c -o program/build/timer.o program/device/timer.c
# i386gcc -I program/lib/ -I program/kernel/ -o program/build/main.o  program/kernel/main.c
# nasm -f elf -o program/build/print.o program/lib/kernel/print.S
# nasm -f elf -o program/build/kernel.o program/kernel/kernel.S
i386gcc -I program/lib/ -I program/kernel/ -c -fno-builtin -o program/build/interrupt.o  program/kernel/interrupt.c
# i386gcc -I program/lib/ -I program/kernel/ -I program/device/ -c -fno-builtin -o program/build/init.o  program/kernel/init.c
i386ld -Ttext 0xc0001500 -e main -o program/build/kernel.bin program/build/main.o program/build/init.o program/build/interrupt.o program/build/print.o program/build/kernel.o program/build/timer.o

echo "Compiling Done. Please check if there is any errors."
read -p "Press any key to continue..."

echo "Writing..."
# dd if=program/build/MBR.bin of=hd60M.img bs=512 count=1 conv=notrunc
# dd if=program/build/loader.bin of=hd60M.img bs=512 count=4 seek=2 conv=notrunc
dd if=program/build/kernel.bin of=hd60M.img bs=512 count=200 seek=9 conv=notrunc

echo "Writing Done."
bochs -f yjybochsrc.disk