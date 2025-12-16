#!/usr/bin/env bash

set -e -x -o pipefail

OCI_EXE=${OCI_EXE:=podman}

dockcross_version=20250109-7bf589c

${OCI_EXE} pull docker.io/dockcross/manylinux_2_28-x64:$dockcross_version
${OCI_EXE} run --rm docker.io/dockcross/manylinux_2_28-x64:$dockcross_version > ./dockcross-x64
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

${OCI_EXE} pull quay.io/pypa/manylinux_2_28_aarch64:$manylinux_version
${OCI_EXE} run -it --rm -v $(pwd):/work quay.io/pypa/manylinux_2_28_aarch64:$manylinux_version /work/manylinux-internal.sh
