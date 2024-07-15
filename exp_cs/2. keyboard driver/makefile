buildDir = program/build
entryPoint = 0xc0001500
cLib = -I program/lib/ -I program/lib/kernel/ -I program/kernel/ -I program/device/ -I program/thread/
asmLib = -I program/boot/include/
cc = i386-elf-gcc
ld = i386-elf-ld
asFlags = -f elf
cFlags = -Wall -m32 -fno-stack-protector $(cLib) -c -fno-builtin -W -Wstrict-prototypes -Wmissing-prototypes
ldFlags = -m elf_i386 -Ttext $(entryPoint) -e main -Map $(buildDir)/kernel.map
# objs = $(BUILD_DIR)/main.o $(BUILD_DIR)/init.o $(BUILD_DIR)/interrupt.o $(BUILD_DIR)/timer.o $(BUILD_DIR)/kernel.o $(BUILD_DIR)/print.o $(BUILD_DIR)/debug.o $(BUILD_DIR)/memory.o $(BUILD_DIR)/bitmap.o $(BUILD_DIR)/string.o $(BUILD_DIR)/thread.o $(BUILD_DIR)/list.o $(BUILD_DIR)/switch.o $(BUILD_DIR)/console.o $(BUILD_DIR)/sync.o $(BUILD_DIR)/keyboard.o

# Dude, makefile is a case sensitive language
# Don't just copy the code and paste it
# Schupid innit ?

objs = $(buildDir)/main.o $(buildDir)/init.o $(buildDir)/interrupt.o $(buildDir)/timer.o $(buildDir)/kernel.o $(buildDir)/print.o $(buildDir)/debug.o $(buildDir)/memory.o $(buildDir)/bitmap.o $(buildDir)/string.o $(buildDir)/thread.o $(buildDir)/list.o $(buildDir)/switch.o $(buildDir)/console.o $(buildDir)/sync.o $(buildDir)/keyboard.o

.PHONY: createBuildDir clean writeHD launchBochs all
# PHONY need to be placed before its targets

all: createBuildDir compile writeHD launchBochs

createBuildDir:
	if [ ! -d $(buildDir) ];	\
		then mkdir $(buildDir);		\
	fi

clean:
	rm -rI $(buildDir)
	cp hd60M_empty.img hd60M.img
	echo "Clean complete."

compile: \
	$(buildDir)/mbr.bin		\
	$(buildDir)/loader.bin	\
	$(buildDir)/kernel.bin	
	echo "Build complete."

writeHD:
	dd if=$(buildDir)/mbr.bin of=hd60M.img bs=512 count=1 conv=notrunc
	dd if=$(buildDir)/loader.bin of=hd60M.img bs=512 count=4 seek=2 conv=notrunc
	dd if=$(buildDir)/kernel.bin of=hd60M.img bs=512 count=200 seek=9 conv=notrunc
	echo "Write to hd complete."

launchBochs:
	read -p "Press any key to launch bochs..."
	bochs -f yjybochsrc.disk


# Compile boot files
$(buildDir)/mbr.bin: program/boot/mbr.S
	nasm $(asmLib) $< -o $@
$(buildDir)/loader.bin: program/boot/loader.S
	nasm $(asmLib) $< -o $@

# Compile C
$(buildDir)/main.o: program/kernel/main.c program/lib/kernel/print.h program/lib/stdint.h program/kernel/init.h program/thread/thread.h
	$(cc) $(cFlags) $< -o $@
$(buildDir)/init.o: program/kernel/init.c program/kernel/init.h program/lib/kernel/print.h program/lib/stdint.h program/kernel/interrupt.h program/device/timer.h
	$(cc) $(cFlags) $< -o $@
$(buildDir)/interrupt.o: program/kernel/interrupt.c program/kernel/interrupt.h program/lib/stdint.h program/kernel/global.h program/lib/kernel/print.h program/lib/kernel/io.h
	$(cc) $(cFlags) $< -o $@
$(buildDir)/timer.o: program/device/timer.c program/device/timer.h program/lib/stdint.h program/lib/kernel/io.h program/lib/kernel/print.h
	$(cc) $(cFlags) $< -o $@
$(buildDir)/debug.o: program/kernel/debug.c program/kernel/debug.h program/lib/kernel/print.h program/lib/stdint.h program/kernel/interrupt.h
	$(cc) $(cFlags) $< -o $@
$(buildDir)/string.o: program/lib/string.c program/lib/string.h program/kernel/global.h program/kernel/debug.h
	$(cc) $(cFlags) $< -o $@
$(buildDir)/bitmap.o: program/lib/kernel/bitmap.c program/lib/kernel/bitmap.h program/kernel/global.h program/lib/string.h program/lib/kernel/print.h program/kernel/debug.h program/kernel/interrupt.h program/lib/stdint.h
	$(cc) $(cFlags) $< -o $@
$(buildDir)/list.o: program/lib/kernel/list.c program/lib/kernel/list.h program/kernel/interrupt.h program/kernel/global.h
	$(cc) $(cFlags) $< -o $@
$(buildDir)/memory.o: program/kernel/memory.c program/kernel/memory.h program/lib/stdint.h program/lib/kernel/bitmap.h program/kernel/global.h program/kernel/debug.h program/lib/kernel/print.h program/lib/kernel/io.h program/kernel/interrupt.h program/lib/string.h
	$(cc) $(cFlags) $< -o $@
$(buildDir)/thread.o: program/thread/thread.c program/thread/thread.h program/lib/stdint.h program/lib/string.c program/kernel/global.h program/kernel/memory.h program/kernel/debug.h program/kernel/interrupt.h program/lib/kernel/print.h program/lib/kernel/list.h
	$(cc) $(cFlags) $< -o $@
$(buildDir)/console.o: program/device/console.c program/device/console.h program/lib/stdint.h program/lib/kernel/print.h program/thread/sync.h program/lib/kernel/list.h program/kernel/global.h program/thread/thread.h
	$(cc) $(cFlags) $< -o $@
$(buildDir)/sync.o: program/thread/sync.c program/thread/sync.h program/lib/kernel/list.h program/kernel/global.h program/lib/stdint.h program/thread/thread.h program/lib/string.h program/lib/stdint.h program/kernel/debug.h program/kernel/interrupt.h
	$(cc) $(cFlags) $< -o $@
$(buildDir)/keyboard.o: program/device/keyboard.c program/device/keyboard.h program/lib/kernel/print.h program/lib/stdint.h program/kernel/interrupt.h program/lib/kernel/io.h program/thread/thread.h program/lib/kernel/list.h program/kernel/global.h program/thread/sync.h program/thread/thread.h
	$(cc) $(cFlags) $< -o $@


# Compile assembly
$(buildDir)/kernel.o: program/kernel/kernel.S
	nasm $(asFlags) $< -o $@
$(buildDir)/print.o: program/lib/kernel/print.S
	nasm $(asFlags) $< -o $@
$(buildDir)/switch.o: program/thread/switch.S
	nasm $(asFlags) $< -o $@

# Link
$(buildDir)/kernel.bin: $(objs)
	$(ld) $(ldFlags) $^ -o $@

