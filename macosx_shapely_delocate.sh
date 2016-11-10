#!/bin/bash

for py in 2.7 3.3 3.4 3.5; do
    mkdir -p delocated_wheels
    mkdir -p shapely/tests
    cp -r src/Shapely/tests shapely/tests
    tmpvenv="${BUILDDIR}/venv_shapely_${py}_delocated"
    virtualenv -p python${py} ${tmpvenv}
    source ${tmpvenv}/bin/activate
    pip install -U pip
    pip install -U delocate
    pip install shapely[test]==$(cat SHAPELY_VERSION.txt) -f wheels
    cd shapely && DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH} python -m pytest
    cd ..
done

parallel delocate-wheel -w delocated_wheels --require-archs=intel -v {} ::: wheels/Shapely*.whl
parallel mv {} dist/{/.}.macosx_10_9_intel.macosx_10_9_x86_64.macosx_10_10_intel.macosx_10_10_x86_64.whl ::: delocated_wheels/Shapely*.whl
