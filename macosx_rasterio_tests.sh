#!/bin/bash

set -e

mkdir -p rasterio
cp -r src/rasterio/tests rasterio

for py in 2.7 3.4 3.5 3.6 3.7; do
    tmpvenv="${BUILDDIR}/venv_rasterio_${py}_test"
    virtualenv -p python${py} ${tmpvenv}
    source ${tmpvenv}/bin/activate
    python get-pip.py
    pip install -U pip
    pip install rasterio[test]==$(cat RASTERIO_VERSION.txt) -f wheels
    cd rasterio && python -m pytest -Wi -k "not test_read_no_band"
    cd ..
done

for whl in wheels/rasterio*.whl; do
    cp ${whl} dist/$(basename ${whl})
done
