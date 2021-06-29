sudo apt-get -y install \
	     binutils build-essential libtool texinfo \
	     gzip zip unzip patchutils curl git \
	     make cmake ninja-build automake bison flex gperf \
	     grep sed gawk python bc \
	     zlib1g-dev libexpat1-dev libmpc-dev \
	     libglib2.0-dev libfdt-dev libpixman-1-dev

mkdir riscv
cd riscv
mkdir _install
export PATH=`pwd`/_install/bin:$PATH
hash -r

# gcc, binutils, newlib
git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
pushd riscv-gnu-toolchain
./configure --prefix=`pwd`/../_install --enable-multilib
make -j`nproc`

# qemu
make -j`nproc` build-qemu
popd
