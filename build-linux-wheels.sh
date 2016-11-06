#!/bin/bash
set -eu

SRC_DIR=$1
cd $SRC_DIR

ORIGINAL_PATH=$PATH
UNREPAIRED_WHEELS=/tmp/wheels

# Compile wheels
for PYBIN in /opt/python/*/bin; do
    if [[ $PYBIN == *"26"* ]]; then continue; fi
    export PATH=${PYBIN}:$ORIGINAL_PATH
    rm -rf build
    PACKAGE_DATA=1 python setup.py bdist_wheel -d ${UNREPAIRED_WHEELS}
done

# Bundle GDAL et al ino the wheels.
for whl in ${UNREPAIRED_WHEELS}/*.whl; do
    auditwheel repair ${whl} -w /io/wheels
done
