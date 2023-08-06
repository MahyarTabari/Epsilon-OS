# needed for the cross compiler used in Makefile
export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"

# if ./build or ./bin directories don't exist, create them
# these are needed for build process
if ![ -d ./build ]; then
	mkdir bin

if ![ -d ./bin ]; then
	mkdir bin


make all
