#!/bin/bash

# This script runs the Superbuild in the thewtex/centos-build docker image
# from CircleCI.  It packages the result and uploads it as an artifact.

die() {
  echo "Error: $@" 1>&2
  exit 1;
}

export CC=/opt/rh/devtoolset-2/root/usr/bin/gcc
export CXX=/opt/rh/devtoolset-2/root/usr/bin/g++

mkdir -p /usr/src/CastXMLSuperbuild-build
cd /usr/src/CastXMLSuperbuild-build || die "Could not cd into the build directory"

cmake \
  -DBUILD_FLAGS:STRING="-j4" \
  /usr/src/CastXMLSuperbuild || die "CMake configuration failed"
make VERBOSE=1 || die "Build failed"
cd castxml-prefix/src/castxml-build
ctest || die "CTest failed"

cd /usr/src/CastXMLSuperbuild-build
tar cvf castxml-linux.tar castxml
gzip -9 castxml-linux.tar
