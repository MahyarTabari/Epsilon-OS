OBJECT_FILES  = ./build/kernel/kernel.asm.o ./build/kernel/kernel.o ./build/include/vga.o ./build/kernel/idt.asm.o ./build/memory/memory.o ./build/kernel/idt.o
FLAGS = -g -ffreestanding -falign-jumps -falign-functions -falign-labels -falign-loops -fstrength-reduce -fomit-frame-pointer -finline-functions -Wno-unused-function -fno-builtin -Werror -Wno-unused-label -Wno-cpp -Wno-unused-parameter -nostdlib -nostartfiles -nodefaultlibs -Wall -O0
INCLUDES = -I./src

all: ./bin/boot.bin ./bin/kernel.bin
	dd if=./bin/boot.bin >> ./bin/os.bin
	dd if=./bin/kernel.bin >> ./bin/os.bin
	dd if=/dev/zero bs=512 count=100 >> ./bin/os.bin


./bin/boot.bin:
	nasm -f bin ./src/boot/boot.asm -o ./bin/boot.bin


./build/kernel/kernel.asm.o:
	nasm -f elf -g ./src/kernel/kernel.asm -o ./build/kernel/kernel.asm.o

./build/kernel/idt.asm.o:
	nasm -f elf -g ./src/kernel/idt.asm -o ./build/kernel/idt.asm.o

./build/kernel/kernel.o:
	i686-elf-gcc $(INCLUDES) $(FLAGS) -std=gnu99 -c ./src/kernel/kernel.c -o ./build/kernel/kernel.o

./bin/kernel.bin:	$(OBJECT_FILES)
	i686-elf-ld -g -relocatable $(OBJECT_FILES) -o ./build/kernel/full-kernel.o
	i686-elf-gcc $(FLAGS) -T ./src/linker/linker.ld -o ./bin/kernel.bin -ffreestanding -O0 -nostdlib ./build/kernel/full-kernel.o

./build/include/vga.o:	./src/include/vga.c
	i686-elf-gcc $(INCLUDES) $(FLAGS) -std=gnu99 -c ./src/include/vga.c -o ./build/include/vga.o

./build/include/vga.o:	./src/include/vga.c
	i686-elf-gcc $(INCLUDES) $(FLAGS) -std=gnu99 -c ./src/include/vga.c -o ./build/include/vga.o

./build/memory/memory.o:	./src/memory/memory.c
	i686-elf-gcc $(INCLUDES) -I./src/memory $(FLAGS) -std=gnu99 -c ./src/memory/memory.c -o ./build/memory/memory.o

./build/kernel/idt.o:	./src/kernel/idt.c
	i686-elf-gcc $(INCLUDES) -I./src/kernel $(FLAGS) -std=gnu99 -c ./src/kernel/idt.c -o ./build/kernel/idt.o
clean:
	rm -rf ./bin/boot.bin
	rm -rf ./bin/kernel.bin
	rm -rf ./bin/os.bin
	rm -rf ./build
	rm -rf ./bin



