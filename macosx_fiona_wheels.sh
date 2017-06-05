#!/bin/bash

set -e

for py in 2.7 3.4 3.5 3.6; do
    tmpvenv="${BUILDDIR}/venv_fiona_${py}_wheels"
    virtualenv -p python${py} ${tmpvenv}
    source ${tmpvenv}/bin/activate
    pip install -U pip wheel
    pip install "numpy>=1.11"
    pip install -r src/Fiona/requirements-dev.txt
    rm -rf build
    pip wheel dist/fiona.tar.gz -w wheels
done

virtualenv -p python3.5 ${BUILDDIR}/delocate
source ${BUILDDIR}/delocate/bin/activate && pip install -U git+https://github.com/matthew-brett/delocate.git@da5a0f7c81a353e939344e27e59f15994bfb6b8f#egg=delocate

for whl in wheels/Fiona*.whl; do
    delocate-wheel --require-archs=intel -v ${whl}
done
