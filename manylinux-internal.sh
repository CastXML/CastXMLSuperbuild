#!/usr/bin/env bash

set -e -x -o pipefail

# This script is executed inside the manylinux container to build castxml for an aarch64 linux system
cd /work

git clone https://github.com/ninja-build/ninja.git
pushd ninja
git checkout release
cmake -DBUILD_TESTING:BOOL=OFF -DCMAKE_BUILD_TYPE:STRING=Release -Bbuild-cmake -S.
cmake --build build-cmake --parallel 8
cp build-cmake/ninja /usr/local/bin/
popd
rm -rf ninja

cmake -Bbuild -S. -GNinja
ninja -Cbuild

pushd build
tar cvf ../castxml-linux-aarch64.tar castxml
gzip -9 ../castxml-linux-aarch64.tar
popd
rm -rf build
