#!/bin/bash

set -e

# Check that Shapely and Fiona wheels are compatible.

VENV1="$(mktemp -d ${TMPDIR}frswb.XXXXXX)/venv1"

virtualenv -p python3.5 ${VENV1}
source ${VENV1}/bin/activate
pip install shapely fiona --pre -f dist

echo "Importing shapely, fiona"
python -c "import shapely; import fiona; f=fiona.open('zip://coutwildrnp.zip'); print(next(f));"

echo "Importing fiona, shapely"
python -c "import fiona; import shapely; f=fiona.open('zip://coutwildrnp.zip'); print(next(f));"

deactivate

# Check for wheel-Homebrew compatibility. We install Rasterio from an sdist,
# linking a system GDAL library, but Fiona from a wheel with its own GDAL
# library.

VENV2="$(mktemp -d ${TMPDIR}frswb.XXXXXX)/venv2"

virtualenv -p python3.5 ${VENV2}
source ${VENV2}/bin/activate
pip install fiona --pre -f dist
pip install cython numpy
pip install rasterio --no-binary rasterio

echo "Importing rasterio (sdist+homebrew), fiona"
python -c "import rasterio; import fiona; f=fiona.open('zip://coutwildrnp.zip'); print(next(f));"

echo "Importing fiona, rasterio (sdist+homebrew)"
python -c "import fiona; import rasterio; f=fiona.open('zip://coutwildrnp.zip'); print(next(f));"

deactivate
