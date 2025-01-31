#!/usr/bin/env bash

set -e -x -o pipefail


dockcross_version=latest

podman pull docker.io/dockcross/manylinux_2_28-x64:$dockcross_version
podman run --rm docker.io/dockcross/manylinux_2_28-x64:$dockcross_version > ./dockcross-x64
chmod +x ./dockcross-x64

./dockcross-x64 cmake -Bbuild -S. -GNinja
./dockcross-x64 ninja -Cbuild

pushd build
tar cvf ../castxml-linux.tar castxml
gzip -9 ../castxml-linux.tar
popd
rm -rf build


manylinux_version=2025.01.24-1

cat << EOF

Note!
Need to run:

  sudo podman run --privileged --rm tonistiigi/binfmt --install all

once before running the following commands on an amd64 system.

EOF

podman pull quay.io/pypa/manylinux_2_28_aarch64:$manylinux_version
podman run -it --rm -v $(pwd):/work quay.io/pypa/manylinux_2_28_aarch64:$manylinux_version /work/manylinux-internal.sh
