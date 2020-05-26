#!/bin/bash

BUILD_PATH=build
OUTPUT_PATH=output
REPO_PATH=repo
IKOS_PATH=ikos
IKOS_GIT=https://github.com/iamwonseok/ikos.git

echo -n "1. create repo directory: "
if [ -d $REPO_PATH ]
then
	echo "SK"
else
	mkdir $REPO_PATH
	echo "OK"
fi
cd $REPO_PATH

echo "2. download ikos: "
if [ ! -d $IKOS_PATH ]
then
	git clone $IKOS_GIT
fi

echo "3. checkout llvm-11 branch"
cd $IKOS_PATH
git checkout llvm-11
cd ../../

echo "4. create build directory"
if [ -d $BUILD_PATH/$IKOS_PATH ]
then
	echo "SK"
else
	mkdir -p $BUILD_PATH/$IKOS_PATH
	echo "OK"
fi

echo "5. create output directory"
if [ -d $OUTPUT_PATH/$IKOS_PATH ]
then
	echo "SK"
else
	mkdir -p $OUTPUT_PATH/$IKOS_PATH
	echo "OK"
fi
cd $BUILD_PATH/$IKOS_PATH

echo "5. start to build ikos"
cmake -DCMAKE_INSTALL_PREFIX="../../$OUTPUT_PATH/ikos" \
	  -DLLVM_CONFIG_EXECUTABLE="../../$OUTPUT_PATH/llvm/bin/llvm-config" \
	  ../../$REPO_PATH/$IKOS_PATH

cmake --build . --target install
