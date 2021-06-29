#!/bin/bash

BUILD_PATH=build
OUTPUT_PATH=output
REPO_PATH=repo
LLVM_PATH=llvm
LLVM_GIT=https://github.com/llvm/llvm-project.git

echo -n "1. create repo directory: "
if [ -d $REPO_PATH ]
then
	echo "SK"
else
	mkdir $REPO_PATH
	echo "OK"
fi
cd $REPO_PATH

echo "2. download llvm: "
if [ ! -d $LLVM_PATH ]
then
	git clone $LLVM_GIT
fi

echo "3. checkout llvm-10 branch"
cd llvm-project
git checkout c1a0a213378a458fbea1a5c77b315c7dce08fd05
cd ..

echo -n "4. create build directory"
cd ..
if [ -d $BUILD_PATH/$LLVM_PATH ]
then
	echo "SK"
else
	mkdir -p $BUILD_PATH/$LLVM_PATH
	echo "OK"
fi

echo -n "5. create output directory"
if [ -d $OUTPUT_PATH/$LLVM_PATH ]
then
	echo "SK"
else
	mkdir -p $OUTPUT_PATH/$LLVM_PATH
	echo "OK"
fi

echo "6. start to build llvm"
cd $BUILD_PATH/$LLVM_PATH
cmake -G Ninja -DCMAKE_BUILD_TYPE="Release" \
	-DBUILD_SHARED_LIBS=True -DLLVM_USE_SPLIT_DWARF=True \
	-DCMAKE_INSTALL_PREFIX="../../$OUTPUT_PATH/llvm" \
	-DLLVM_OPTIMIZED_TABLEGEN=True -DLLVM_BUILD_TESTS=False \
	-DDEFAULT_SYSROOT="/opt/riscv/gcc" \
	-DLLVM_DEFAULT_TARGET_TRIPLE="riscv64-unknown-elf" \
	-DLLVM_TARGETS_TO_BUILD="RISCV" \
	-DLLVM_ENABLE_RTTI=ON \
	-DLLVM_INCLUDE_UTILS=ON \
	-DLLVM_ENABLE_PROJECTS=clang -G "Unix Makefiles" \
	../../$REPO_PATH/llvm-project/$LLVM_PATH

cmake --build . --target install

echo "6. end to build llvm"
cd ../../
