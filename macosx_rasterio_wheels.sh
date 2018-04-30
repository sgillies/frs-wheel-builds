#!/bin/bash

set -e

for py in 2.7 3.4 3.5 3.6; do
    tmpvenv="${BUILDDIR}/venv_rasterio_${py}_wheels"
    virtualenv -p python${py} ${tmpvenv}
    source ${tmpvenv}/bin/activate
    python get-pip.py
    pip install -U pip wheel
    pip install "numpy>=1.11"
    pip install -r src/rasterio/requirements-dev.txt
    pip wheel dist/rasterio.tar.gz --no-deps -w wheels
done

virtualenv -p python3.5 ${BUILDDIR}/delocate
source ${BUILDDIR}/delocate/bin/activate && pip install -U git+https://github.com/matthew-brett/delocate.git@da5a0f7c81a353e939344e27e59f15994bfb6b8f#egg=delocate

for whl in wheels/rasterio*.whl; do
    delocate-wheel --require-archs=intel -v ${whl}
done
