#!/bin/bash
set -e
err() {
    echo "Error occurred:"
    awk 'NR>L-4 && NR<L+4 { printf "%-5d%3s%s\n",NR,(NR==L?">>>":""),$0 }' L=$1 $0
	echo "Press Enter to continue"
	read
	exit 1
}
trap 'err $LINENO' ERR

basepath=$(cd `dirname $0`; pwd)
cd $basepath

IMAGE=jetbrainsruntime-for-ubuntu-1604

docker build . -t $IMAGE
mkdir build|| true
rm -f /build/jbr-linux-x64.zip || true
MSYS_NO_PATHCONV=1 docker run --rm -v $(pwd)/build:/build $IMAGE bash -c "cat /root/JetBrainsRuntime/build/linux-x86_64-normal-server-release/images/jbr-linux-x64.zip > /build/jbr-linux-x64.zip"

echo "Finish, press 'Enter' key to exit"
read