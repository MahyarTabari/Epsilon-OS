#
#    August 2023
#
#
#    This script is used for installing dependecies needed for the cross compiler
#    The GCC and binutils source will be downloaded into $HOME/src
#    Then the cross compiler will be installed in $HOME/opt/cross/bin
#
#    to check whether the new cross-compiler works or not, run the below command:
#    $HOME/opt/cross/bin/$TARGET-gcc --version
#
#




#!/bin/bash

# uncomment the below line to set the cross-compiler as the default gcc compiler of your system
# export PATH="$HOME/opt/cross/bin:$PATH"


export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"

# check the existance of dependencies and install them(if they are not installed)
package_names=('build-essential' 'bison' 'flex' 'libgmp3-dev' 'libmpc-dev' 'libmpfr-dev' 'texinfo' 'libvloog-isl-dev' 'libisl-dev')
for package in "${package_names[@]}"
do
    if [ -z $(dpkg-query -W -f='$${Status}' "${package}" 2>/dev/null | grep -c "ok installed") ]
    then
        echo "${package} is not installed"
        echo "installing ${package}..."
        sudo apt-get install "${package}" -y
    else
        echo "$${package} is already installed"
    fi
done


# downloading sources of bintuils and gcc
wget -P $HOME/src/ "https://ftp.gnu.org/gnu/binutils/binutils-2.35.tar.gz"
wget -P $HOME/src/ "https://ftp.gnu.org/gnu/gcc/gcc-10.2.0/gcc-10.2.0.tar.gz"
	

# extracting downloaded sources
echo "extracting binutils..."
tar -xvzf $HOME/src/binutils*.tar.gz
echo "extracting gcc..."
tar -xvzf $HOME/src/gcc*.tar.gz


# installing binutils
cd $HOME/src
mkdir build_binutils
cd build_binutils
../binutils-2.35/configure --target="$TARGET" --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
make
make install


# installing gcc	
cd $HOME/src

which -- $TARGET-as || echo $TARGET-as is not in the PATH

mkdir build-gcc
cd build-gcc
../gcc-10.2.0/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers
make all-gcc
make all-target-libgcc
make install-gcc
make install-target-libgcc
