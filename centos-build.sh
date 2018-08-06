#!/bin/bash

# This script runs the Superbuild in the dockbuild/centos7 docker image
# from CircleCI.  It packages the result and uploads it as an artifact.

set -x

die() {
  echo "Error: $@" 1>&2
  exit 1;
}

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
