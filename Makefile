SHELL = /bin/bash
CWD := $(shell pwd)

LAST_TAG_COMMIT = $$(git rev-list --tags --max-count=1)
VERSION = $$(git describe --tags $(LAST_TAG_COMMIT) )

MACOSX_DEPLOYMENT_TARGET = 10.9
CFLAGS = -arch i386 -arch x86_64
CXXFLAGS = -arch i386 -arch x86_64

GEOS_CONFIG = "$(CWD)/parts/geos/bin/geos-config"
GDAL_CONFIG = "$(CWD)/parts/gdal/bin/gdal-config"
PROJ_LIB = "$(CWD)parts/proj4/share/proj"
DYLD_LIBRARY_PATH = "$(CWD)/parts/gdal/lib:$(CWD)/parts/geos/lib:$(CWD)/parts/openjpeg/lib:$(CWD)/parts/json-c/lib:$(CWD)/parts/proj4/lib:$(CWD)/parts/hdf5/lib:$(CWD)/parts/netcdf/lib"

BUILDDIR := $(shell mktemp -d $(TMPDIR)frswb.XXXXXX)

all: fiona rasterio shapely

parts: buildout.cfg
	buildout -c buildout.cfg

dist:
	mkdir -p dist

wheels:
	mkdir -p wheels

src/Shapely/.git:
	git clone https://github.com/Toblerity/Shapely.git src/Shapely

src/Fiona/.git:
	git clone https://github.com/Toblerity/Fiona.git src/Fiona

src/rasterio/.git:
	git clone https://github.com/mapbox/rasterio.git src/rasterio

dist/shapely.tar.gz: src/Shapely/.git dist
	virtualenv -p python3.5 $(BUILDDIR)/sdist && \
	source $(BUILDDIR)/sdist/bin/activate && \
	pip install -U pip && \
	pip install "numpy>=1.11" && \
	cd src/Shapely && \
	git fetch --tags && git checkout $(VERSION) && \
	pip install -r requirements-dev.txt && \
	python setup.py --version | tail -1 > ../../SHAPELY_VERSION.txt && \
	python setup.py sdist
	cp src/Shapely/dist/*.tar.gz dist
	cp dist/Shapely*.tar.gz dist/shapely.tar.gz

dist/fiona.tar.gz: src/Fiona/.git dist
	virtualenv -p python3.5 $(BUILDDIR)/sdist && \
	source $(BUILDDIR)/sdist/bin/activate && \
	pip install -U pip && \
	pip install "numpy>=1.11" && \
	cd src/Fiona && \
	git fetch --tags && git checkout $(VERSION) && \
	pip install -r requirements-dev.txt && \
	python setup.py --version | tail -1 > ../../FIONA_VERSION.txt && \
	python setup.py sdist
	cp src/Fiona/dist/*.tar.gz dist
	cp dist/Fiona*.tar.gz dist/fiona.tar.gz

dist/rasterio.tar.gz: src/rasterio/.git dist
	virtualenv -p python3.5 $(BUILDDIR)/sdist && \
	source $(BUILDDIR)/sdist/bin/activate && \
	pip install -U pip && \
	pip install "numpy>=1.11" && \
	cd src/rasterio && \
	git fetch --tags && git checkout $(VERSION) && \
	pip install -r requirements-dev.txt && \
	python setup.py --version | tail -1 > ../../RASTERIO_VERSION.txt && \
	which python && pip list && python -c "import numpy; print(numpy.__version__)" && \
	python setup.py sdist
	cp src/rasterio/dist/*.tar.gz dist
	cp dist/rasterio*.tar.gz dist/rasterio.tar.gz

.wheelbuilder_image_built: Dockerfile.wheels
	docker build -f Dockerfile.wheels -t wheelbuilder .
	touch .wheelbuilder_image_built

shapely_wheels: dist/shapely.tar.gz wheels
	BUILDDIR=$(BUILDDIR) MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GEOS_CONFIG) --cflags)" LDFLAGS="$$($(GEOS_CONFIG) --clibs) $(CFLAGS)" ./macosx_shapely_wheels.sh

shapely_macosx: shapely_wheels
	DYLD_LIBRARY_PATH=$(DYLD_LIBRARY_PATH) BUILDDIR=$(BUILDDIR) ./macosx_shapely_tests.sh
	parallel rename -e "s/macosx_10_6\.intel/macosx_10_9_intel.macosx_10_9_x86_64/" {} ::: dist/Shapely*.whl

shapely_manylinux1: dist .wheelbuilder_image_built build-linux-wheels.sh dist/shapely.tar.gz
	docker run -v $(CURDIR):/io wheelbuilder bash -c "/io/build-linux-wheels.sh /io/dist/shapely.tar.gz"

shapely: dist/shapely.tar.gz shapely_macosx shapely_manylinux1

fiona_wheels: dist/fiona.tar.gz wheels
	BUILDDIR=$(BUILDDIR) MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" GDAL_VERSION="2" ./macosx_fiona_wheels.sh

fiona_macosx: fiona_wheels
	DYLD_LIBRARY_PATH=$(DYLD_LIBRARY_PATH) BUILDDIR=$(BUILDDIR) ./macosx_fiona_tests.sh
	parallel rename -e "s/macosx_10_6\.intel/macosx_10_9_intel.macosx_10_9_x86_64/" {} ::: dist/Fiona*.whl

fiona_manylinux1: dist .wheelbuilder_image_built build-linux-wheels.sh dist/fiona.tar.gz
	docker run -v $(CURDIR):/io wheelbuilder bash -c "/io/build-linux-wheels.sh /io/dist/fiona.tar.gz"

fiona: dist/fiona.tar.gz fiona_macosx fiona_manylinux1

rasterio_wheels: dist/rasterio.tar.gz wheels
	BUILDDIR=$(BUILDDIR) MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" ./macosx_rasterio_wheels.sh

rasterio_macosx: rasterio_wheels
	DYLD_LIBRARY_PATH=$(DYLD_LIBRARY_PATH) BUILDDIR=$(BUILDDIR) ./macosx_rasterio_tests.sh
	parallel rename -e "s/macosx_10_6\.intel/macosx_10_9_intel.macosx_10_9_x86_64/" {} ::: dist/rasterio*.whl

rasterio_manylinux1: dist .wheelbuilder_image_built build-linux-wheels.sh dist/rasterio.tar.gz
	docker run -v $(CURDIR):/io wheelbuilder bash -c "/io/build-linux-wheels.sh /io/dist/rasterio.tar.gz"

rasterio: dist/rasterio.tar.gz rasterio_macosx rasterio_manylinux1

clean:
	rm -rf .wheelbuilder_image_built
	rm -rf *VERSION.txt
	rm -rf shapely
	rm -rf fiona
	rm -rf rasterio
	rm -rf dist
	rm -rf wheels
	rm -rf src/Fiona
	rm -rf src/rasterio
	rm -rf src/Shapely
