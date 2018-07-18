#!/bin/bash

set -e

mkdir -p rio-color
cp -r src/rio-color/tests rio-color

for py in 2.7 3.4 3.5 3.6 3.7; do
    tmpvenv="${BUILDDIR}/venv_rio-color_${py}_test"
    virtualenv -p python${py} ${tmpvenv}
    source ${tmpvenv}/bin/activate
    python get-pip.py
    pip install -U pip
    pip install rio-color[test]==$(cat RIO_COLOR_VERSION.txt) -f wheels
    cd rio-color && python -m pytest
    cd ..
done

for whl in wheels/rio_color*.whl; do
    cp ${whl} dist/$(basename ${whl})
done
