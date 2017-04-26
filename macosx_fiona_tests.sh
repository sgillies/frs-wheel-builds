#!/bin/bash

set -e

mkdir -p fiona
cp -r src/Fiona/tests fiona

for py in 2.7 3.4 3.5; do
    tmpvenv="${BUILDDIR}/venv_fiona_${py}_test"
    virtualenv -p python${py} ${tmpvenv}
    source ${tmpvenv}/bin/activate
    pip install -U pip
    pip install pytest fiona[test]==$(cat FIONA_VERSION.txt) -f wheels
    cd fiona && DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH} nosetests --exclude test_filter_vsi --exclude test_geopackage --exclude test_write_mismatch --exclude test_fio_ls
    cd ..
done

for whl in wheels/Fiona*.whl; do
    cp ${whl} dist/$(basename ${whl})
done
