SHELL = /bin/bash

LAST_TAG_COMMIT = $$(git rev-list --tags --max-count=1)
VERSION = $$(git describe --tags $(LAST_TAG_COMMIT) )

MACOSX_DEPLOYMENT_TARGET = 10.6
CFLAGS = -arch i386 -arch x86_64
CXXFLAGS = -arch i386 -arch x86_64
GEOS_CONFIG = "parts/geos/bin/geos-config"
GDAL_CONFIG = "parts/gdal/bin/gdal-config"
PROJ_LIB = "parts/proj4/share/proj"
DYLD_LIBRARY_PATH = "../parts/gdal/lib:../parts/geos/lib:../parts/jasper/lib:../parts/json-c/lib:../parts/proj4/lib"

BUILDDIR := $(shell mktemp -d $(TMPDIR)frswb.XXXXXX)

all: fiona_sdist fiona_dist rasterio_sdist rasterio_macosx rasterio_manylinux1 shapely

bin:
	python bootstrap.py

parts: bin buildout.cfg
	./bin/buildout -c buildout.cfg

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
	pip install numpy==1.10.4 && \
	cd src/Shapely && \
	git fetch --tags && git checkout $(VERSION) && \
	pip install -r requirements-dev.txt && \
	python setup.py --version > ../../SHAPELY_VERSION.txt && \
	python setup.py sdist
	cp src/Shapely/dist/*.tar.gz dist
	cp dist/Shapely*.tar.gz dist/shapely.tar.gz

dist/fiona.tar.gz: src/Fiona/.git dist
	virtualenv -p python3.5 $(BUILDDIR)/sdist && \
	source $(BUILDDIR)/sdist/bin/activate && \
	pip install -U pip && \
	pip install numpy==1.10.4 && \
	cd src/Fiona && \
	git fetch --tags && git checkout $(VERSION) && \
	pip install -r requirements-dev.txt && \
	python setup.py --version > ../../FIONA_VERSION.txt && \
	python setup.py sdist
	cp src/Fiona/dist/*.tar.gz dist
	ln -s dist/Fiona*.tar.gz dist/fiona.tar.gz

dist/rasterio.tar.gz: src/rasterio/.git dist
	virtualenv -p python3.5 $(BUILDDIR)/sdist && \
	source $(BUILDDIR)/sdist/bin/activate && \
	pip install -U pip && \
	pip install numpy==1.10.4 && \
	cd src/rasterio && \
	git fetch --tags && git checkout $(VERSION) && \
	pip install -r requirements-dev.txt && \
	python setup.py --version > ../../RASTERIO_VERSION.txt && \
	python setup.py sdist
	cp src/rasterio/dist/*.tar.gz dist
	ln -s dist/rasterio*.tar.gz dist/rasterio.tar.gz

wheels_shapely: dist/shapely.tar.gz wheels
	BUILDDIR=$(BUILDDIR) MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GEOS_CONFIG) --cflags)" LDFLAGS="$$($(GEOS_CONFIG) --clibs) $(CFLAGS)" ./macosx_shapely_wheels.sh


delocated_wheels_shapely: wheels_shapely
	DYLD_LIBRARY_PATH=$(DYLD_LIBRARY_PATH) BUILDDIR=$(BUILDDIR) MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GEOS_CONFIG) --cflags)" LDFLAGS="$$($(GEOS_CONFIG) --clibs) $(CFLAGS)" ./macosx_shapely_delocate.sh


shapely_macosx: delocated_wheels_shapely_27

shapely: shapely_sdist shapely_macosx shapely_manylinux1





rasterio_27: src/rasterio/.git parts venv27
	source venv27/bin/activate && \
	cd src/rasterio && \
	git fetch --tags && \
	git checkout $(VERSION) && \
	pip install -r requirements-dev.txt && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" pip install -e .[test] && \
	DYLD_LIBRARY_PATH=$(DYLD_LIBRARY_PATH) py.test -k "not test_read_no_band" && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" python setup.py sdist bdist_wheel

rasterio_33: src/rasterio/.git parts venv33
	source venv33/bin/activate && \
	cd src/rasterio && \
	git fetch --tags && \
	git checkout $(VERSION) && \
	pip install -r requirements-dev.txt && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" pip install -e .[test] && \
	DYLD_LIBRARY_PATH=$(DYLD_LIBRARY_PATH) py.test -k "not test_read_no_band" && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" python setup.py sdist bdist_wheel

rasterio_34: src/rasterio/.git parts venv34
	source venv34/bin/activate && \
	cd src/rasterio && \
	git fetch --tags && \
	git checkout $(VERSION) && \
	pip install -r requirements-dev.txt && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" pip install -e .[test] && \
	DYLD_LIBRARY_PATH=$(DYLD_LIBRARY_PATH) py.test -k "not test_read_no_band" && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" python setup.py sdist bdist_wheel

rasterio_35: src/rasterio/.git parts venv35
	source venv35/bin/activate && \
	cd src/rasterio && \
	git fetch --tags && \
	git checkout $(VERSION) && \
	pip install -r requirements-dev.txt && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" pip install -e .[test] && \
	DYLD_LIBRARY_PATH=$(DYLD_LIBRARY_PATH) py.test -k "not test_read_no_band" && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" python setup.py sdist bdist_wheel

rasterio_manylinux1: dist .image-built build-linux-wheels.sh src/rasterio/.git
	docker run -v $(CURDIR):/io rasterio-wheelbuilder bash -c "/io/build-linux-wheels.sh /io/src/rasterio"

fiona_manylinux1: dist .image-built build-linux-wheels.sh src/Fiona/.git
	docker run -v $(CURDIR):/io rasterio-wheelbuilder bash -c "/io/build-linux-wheels.sh /io/src/Fiona"

shapely_manylinux1: dist .image-built build-linux-wheels.sh src/Shapely/.git
	docker run -v $(CURDIR):/io rasterio-wheelbuilder bash -c "/io/build-linux-wheels.sh /io/src/Shapely"

.image-built: Dockerfile.wheels src/rasterio/.git
	docker build -f Dockerfile.wheels -t rasterio-wheelbuilder .
	touch .image_built

rasterio_sdist: dist rasterio_27 rasterio_34 rasterio_35
	cp src/rasterio/dist/*gz dist

rasterio_macosx: dist rasterio_27 rasterio_33 rasterio_34 rasterio_35
	source venv27/bin/activate && \
	parallel delocate-wheel -w src/rasterio/delocated --require-archs=intel -v {} ::: src/rasterio/dist/*.whl
	parallel mv {} dist/{/.}.macosx_10_9_intel.macosx_10_9_x86_64.macosx_10_10_intel.macosx_10_10_x86_64.whl ::: src/rasterio/delocated/*.whl

rasterio_wheels: rasterio_macosx rasterio_manylinux

fiona_27: src/Fiona/.git parts venv27
	source venv27/bin/activate && \
	cd src/Fiona && \
	git fetch --tags && \
	git checkout $(VERSION) && \
	pip install -r requirements-dev.txt && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" pip install -e . && \
	DYLD_LIBRARY_PATH=$(DYLD_LIBRARY_PATH) nosetests --exclude test_filter_vsi --exclude test_geopackage --exclude test_write_mismatch && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" python setup.py sdist bdist_wheel

fiona_34: src/fiona/.git parts venv34
	source venv34/bin/activate && \
	cd src/fiona && \
	git fetch --tags && \
	git checkout $(VERSION) && \
	pip install -r requirements-dev.txt && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" pip install -e . && \
	DYLD_LIBRARY_PATH=$(DYLD_LIBRARY_PATH) nosetests --exclude test_filter_vsi --exclude test_geopackage --exclude test_write_mismatch && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" python setup.py sdist bdist_wheel

fiona_35: src/fiona/.git parts venv35
	source venv35/bin/activate && \
	cd src/fiona && \
	git fetch --tags && \
	git checkout $(VERSION) && \
	pip install -r requirements-dev.txt && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" pip install -e . && \
	DYLD_LIBRARY_PATH=$(DYLD_LIBRARY_PATH) nosetests --exclude test_filter_vsi --exclude test_geopackage --exclude test_write_mismatch && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" python setup.py sdist bdist_wheel

fiona_sdist: dist fiona_27 fiona_34 fiona_35
	cp src/fiona/dist/*gz dist

fiona_dist: dist fiona_27 fiona_34 fiona_35
	source venv27/bin/activate && \
	parallel delocate-wheel -w src/fiona/delocated --require-archs=intel -v {} ::: src/fiona/dist/*.whl
	parallel mv {} dist/{/.}.macosx_10_9_intel.macosx_10_9_x86_64.macosx_10_10_intel.macosx_10_10_x86_64.whl ::: src/fiona/delocated/*.whl

clean:
	rm -rf wheels_shapely_*
	rm -rf delocated_wheels_shapely_*
	rm -rf shapely
	rm -rf dist
	rm -rf wheels
	rm -rf src/Fiona
	rm -rf src/rasterio
	rm -rf src/Shapely
