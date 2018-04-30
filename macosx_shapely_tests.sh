#!/bin/bash

set -e

mkdir -p shapely
cp -r src/Shapely/tests shapely

for py in 2.7 3.4 3.5; do
    tmpvenv="${BUILDDIR}/venv_shapely_${py}_test"
    virtualenv -p python${py} ${tmpvenv}
    source ${tmpvenv}/bin/activate
    python get-pip.py
    pip install -U pip
    pip install shapely[test]==$(cat SHAPELY_VERSION.txt) -f wheels
    cd shapely && DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH} python -m pytest
    cd ..
done

for whl in wheels/Shapely*.whl; do
    cp ${whl} dist/$(basename ${whl})
done
