KERNEL_OBJECT_FILES  = ./build/kernel.asm.o ./build/kernel.o
FLAGS = -g -ffreestanding -falign-jumps -falign-functions -falign-labels -falign-loops -fstrength-reduce -fomit-frame-pointer -finline-functions -Wno-unused-function -fno-builtin -Werror -Wno-unused-label -Wno-cpp -Wno-unused-parameter -nostdlib -nostartfiles -nodefaultlibs -Wall -O0

all: ./bin/boot.bin ./bin/kernel.bin
	dd if=./bin/boot.bin >> ./bin/os.bin
	dd if=./bin/kernel.bin >> ./bin/os.bin
	dd if=/dev/zero bs=512 count=100 >> ./bin/os.bin


./bin/boot.bin:
	nasm -f bin ./src/boot/boot.asm -o ./bin/boot.bin


./build/kernel.asm.o:
	nasm -f elf -g ./src/kernel/kernel.asm -o ./build/kernel.asm.o


./build/kernel.o:
	i686-elf-gcc $(INCLUDES) $(FLAGS) -std=gnu99 -c ./src/kernel/kernel.c -o ./build/kernel.o

./bin/kernel.bin:	$(KERNEL_OBJECT_FILES)
	i686-elf-ld -g -relocatable $(KERNEL_OBJECT_FILES) -o ./build/full-kernel.o
	i686-elf-gcc $(FLAGS) -T ./src/linker/linker.ld -o ./bin/kernel.bin -ffreestanding -O0 -nostdlib ./build/full-kernel.o

clean:
	rm -rf ./bin/boot.bin
	rm -rf ./bin/kernel.bin
	rm -rf ./bin/os.bin
	rm -rf ./build/* 



