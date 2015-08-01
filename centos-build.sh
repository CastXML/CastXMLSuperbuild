#!/bin/bash

# This script runs the Superbuild in the thewtex/centos-build docker image
# from CircleCI.  It packages the result and uploads it as an artifact.

die() {
  echo "Error: $@" 1>&2
  exit 1;
}

export CC=/opt/rh/devtoolset-2/root/usr/bin/gcc
export CXX=/opt/rh/devtoolset-2/root/usr/bin/g++

cd /usr/src/CastXMLSuperbuild-build || die "Could not cd into the build directory"

cmake \
  /usr/src/CastXMLSuperbuild || die "CMake configuration failed"
make VERBOSE=1 || die "Build failed"

mv castxml castxml-linux
tar cvf castxml-linux.tar castxml-linux
gzip -9 castxml-linux.tar
