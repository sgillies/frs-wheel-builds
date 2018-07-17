#!/bin/bash

set -e

mkdir -p fiona
cp -r src/Fiona/tests fiona

for py in 2.7 3.4 3.5 3.6 3.7; do
    tmpvenv="${BUILDDIR}/venv_fiona_${py}_test"
    virtualenv -p python${py} ${tmpvenv}
    source ${tmpvenv}/bin/activate
    python get-pip.py
    pip install -U pip
    pip install pytest fiona[test]==$(cat FIONA_VERSION.txt) -f wheels
    cd fiona && DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH} python -c "from tests import setup; setup()" && DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH} python -m pytest -k "not testCreateBigIntSchema and not test_write_one"
    cd ..
done

for whl in wheels/Fiona*.whl; do
    cp ${whl} dist/$(basename ${whl})
done
