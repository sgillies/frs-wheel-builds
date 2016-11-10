#!/bin/bash

for py in 2.7 3.3 3.4 3.5; do
    tmpvenv="${BUILDDIR}/venv_shapely_${py}_wheels"
    virtualenv -p python${py} ${tmpvenv}
    source ${tmpvenv}/bin/activate
    pip install -U pip
    pip install -U wheel delocate
    pip install numpy==1.10.4
    pip install -r src/Shapely/requirements-dev.txt
    pip wheel dist/shapely.tar.gz -w wheels
done
