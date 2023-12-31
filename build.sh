# needed for the cross compiler used in Makefile
export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"

# if ./build or ./bin directories don't exist, create them
# these are needed for build process
if [[ ! -d ./build ]]; then
	mkdir build
	mkdir ./build/kernel
	mkdir ./build/kernel/idt
	mkdir ./build/include
	mkdir ./build/memory
	mkdir ./build/memory/heap
	mkdir ./build/memory/paging
	mkdir ./build/io
	mkdir ./build/io/disk
fi

if [[ ! -d ./bin ]]; then
	mkdir bin
fi

make all
