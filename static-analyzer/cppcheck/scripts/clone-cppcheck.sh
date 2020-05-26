#!/bin/bash

BUILD_PATH=build
OUTPUT_PATH=output
REPO_PATH=repo
CPPCHECK_PATH=cppcheck
CPPCHECK_GIT=https://github.com/danmar/cppcheck.git

echo -n "1. create repo directory: "
if [ -d $REPO_PATH ]
then
	echo "SK"
else
	mkdir $REPO_PATH
	echo "OK"
fi
cd $REPO_PATH

echo "2. download cppcheck: "
if [ ! -d $CPPCHECK_PATH ]
then
	git clone $CPPCHECK_GIT
fi

echo "3. create build directory"
cd ..
if [ -d $BUILD_PATH/$CPPCHECK_PATH ]
then
	echo "SK"
else
	mkdir -p $BUILD_PATH/$CPPCHECK_PATH
	echo "OK"
fi

echo "5. create output directory"
if [ -d $OUTPUT_PATH/$CPPCHECK_PATH ]
then
	echo "SK"
else
	mkdir -p $OUTPUT_PATH/$CPPCHECK_PATH
	echo "OK"
fi

echo "5. start to build cppcheck"
cd $BUILD_PATH/$CPPCHECK_PATH
cmake -DCMAKE_INSTALL_PREFIX="../../$OUTPUT_PATH/cppcheck" \
      -DCLANG_TIDY="../../$OUTPUT_PATH/llvm/bin/clang-tidy" \
	  ../../$REPO_PATH/$CPPCHECK_PATH

cmake --build . --target install
