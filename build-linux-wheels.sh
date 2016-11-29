#!/bin/bash
set -eu

SRCDIST=$1
ORIGINAL_PATH=$PATH
UNREPAIRED_WHEELS=/tmp/wheels

# Compile wheels
for PYBIN in /opt/python/*/bin; do
    if [[ $PYBIN == *"26"* ]]; then continue; fi
    export PATH=${PYBIN}:$ORIGINAL_PATH
    CFLAGS="-I/usr/local/ssl/include" LDFLAGS="-L/usr/local/ssl/lib" PACKAGE_DATA=1 pip wheel $SRCDIST --no-deps -w ${UNREPAIRED_WHEELS}
done

# Bundle GDAL et al into the wheels.
for whl in ${UNREPAIRED_WHEELS}/*.whl; do
    auditwheel repair ${whl} -w /io/dist
done
