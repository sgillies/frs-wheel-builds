SHELL = /bin/bash

LAST_TAG_COMMIT = $$(git rev-list --tags --max-count=1)
VERSION = $$(git describe --tags $(LAST_TAG_COMMIT) )

MACOSX_DEPLOYMENT_TARGET = 10.6
CFLAGS = -arch i386 -arch x86_64
CXXFLAGS = -arch i386 -arch x86_64
GEOS_CONFIG = "../../parts/geos/bin/geos-config"
GDAL_CONFIG = "../../parts/gdal/bin/gdal-config"
PROJ_LIB = "../../parts/proj4/share/proj"

all: fiona_sdist fiona_dist rasterio_sdist rasterio_dist shapely_sdist shapely_dist

bin:
	python bootstrap.py

parts: bin buildout.cfg
	./bin/buildout -c buildout.cfg

venv27:
	virtualenv -p python2.7 venv27 && \
	source venv27/bin/activate && \
	pip install -U pip && \
	pip install -U wheel delocate && \
	pip install numpy==1.10.4

venv34:
	virtualenv -p python3.4 venv34
	source venv34/bin/activate && \
	pip install -U pip && \
	pip install -U wheel delocate && \
	pip install numpy==1.10.4

venv35:
	virtualenv -p python3.5 venv35
	source venv35/bin/activate && \
	pip install -U pip && \
	pip install -U wheel delocate && \
	pip install numpy==1.10.4

dist:
	mkdir dist

src/Shapely/.git:
	git clone https://github.com/Toblerity/Shapely.git src/Shapely

shapely_27: src/Shapely/.git parts venv27
	source venv27/bin/activate && \
	cd src/Shapely && \
	git fetch --tags && \
	git checkout $(VERSION) && \
	pip install -r requirements-dev.txt && \
	touch shapely/vectorized/*.pyx && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GEOS_CONFIG) --cflags)" LDFLAGS="$$($(GEOS_CONFIG) --libs) $(CFLAGS)" pip install -e . && \
	py.test -k 'not VectorizedTouchesTestCase' && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GEOS_CONFIG) --cflags)" LDFLAGS="$$($(GEOS_CONFIG) --libs) $(CFLAGS)" python setup.py sdist bdist_wheel

shapely_34: src/Shapely/.git parts venv34
	source venv34/bin/activate && \
	cd src/Shapely && \
	git fetch --tags && \
	git checkout $(VERSION) && \
	pip install -r requirements-dev.txt && \
	touch shapely/vectorized/*.pyx && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GEOS_CONFIG) --cflags)" LDFLAGS="$$($(GEOS_CONFIG) --libs) $(CFLAGS)" pip install -e . && \
	py.test -k 'not VectorizedTouchesTestCase' && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GEOS_CONFIG) --cflags)" LDFLAGS="$$($(GEOS_CONFIG) --libs) $(CFLAGS)" python setup.py sdist bdist_wheel

shapely_35: src/Shapely/.git parts venv35
	source venv35/bin/activate && \
	cd src/Shapely && \
	git fetch --tags && \
	git checkout $(VERSION) && \
	pip install -r requirements-dev.txt && \
	touch shapely/vectorized/*.pyx && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GEOS_CONFIG) --cflags)" LDFLAGS="$$($(GEOS_CONFIG) --libs) $(CFLAGS)" pip install -e . && \
	py.test -k 'not VectorizedTouchesTestCase' && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GEOS_CONFIG) --cflags)" LDFLAGS="$$($(GEOS_CONFIG) --libs) $(CFLAGS)" python setup.py sdist bdist_wheel


shapely_sdist: dist shapely_27 shapely_34 shapely_35
	cp src/Shapely/dist/*gz dist

shapely_dist: dist shapely_27 shapely_34 shapely_35
	source venv27/bin/activate && \
	parallel delocate-wheel -w src/Shapely/delocated --require-archs=intel -v {} ::: src/Shapely/dist/*.whl
	parallel mv {} dist/{/.}.macosx_10_9_intel.macosx_10_9_x86_64.macosx_10_10_intel.macosx_10_10_x86_64.whl ::: src/Shapely/delocated/*.whl

src/rasterio/.git:
	git clone https://github.com/mapbox/rasterio.git src/rasterio

rasterio_27: src/rasterio/.git parts venv27
	source venv27/bin/activate && \
	cd src/rasterio && \
	git fetch --tags && \
	git checkout $(VERSION) && \
	pip install -r requirements-dev.txt && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" pip install -e .[s3] && \
	py.test -k "not test_read_no_band" && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" python setup.py sdist bdist_wheel

rasterio_34: src/rasterio/.git parts venv34
	source venv34/bin/activate && \
	cd src/rasterio && \
	git fetch --tags && \
	git checkout $(VERSION) && \
	pip install -r requirements-dev.txt && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" pip install -e .[s3] && \
	py.test -k "not test_read_no_band" && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" python setup.py sdist bdist_wheel

rasterio_35: src/rasterio/.git parts venv35
	source venv35/bin/activate && \
	cd src/rasterio && \
	git fetch --tags && \
	git checkout $(VERSION) && \
	pip install -r requirements-dev.txt && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" pip install -e .[s3] && \
	py.test -k "not test_read_no_band" && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" python setup.py sdist bdist_wheel

rasterio_sdist: dist rasterio_27 rasterio_34 rasterio_35
	cp src/rasterio/dist/*gz dist

rasterio_dist: dist rasterio_27 rasterio_34 rasterio_35
	source venv27/bin/activate && \
	parallel delocate-wheel -w src/rasterio/delocated --require-archs=intel -v {} ::: src/rasterio/dist/*.whl
	parallel mv {} dist/{/.}.macosx_10_9_intel.macosx_10_9_x86_64.macosx_10_10_intel.macosx_10_10_x86_64.whl ::: src/rasterio/delocated/*.whl

src/Fiona/.git:
	git clone https://github.com/Toblerity/Fiona.git src/Fiona

fiona_27: src/Fiona/.git parts venv27
	source venv27/bin/activate && \
	cd src/Fiona && \
	git fetch --tags && \
	git checkout $(VERSION) && \
	pip install -r requirements-dev.txt && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" pip install -e . && \
	nosetests --exclude test_filter_vsi --exclude test_geopackage && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" python setup.py sdist bdist_wheel

fiona_34: src/fiona/.git parts venv34
	source venv34/bin/activate && \
	cd src/fiona && \
	git fetch --tags && \
	git checkout $(VERSION) && \
	pip install -r requirements-dev.txt && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" pip install -e . && \
	nosetests --exclude test_filter_vsi --exclude test_geopackage && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" python setup.py sdist bdist_wheel

fiona_35: src/fiona/.git parts venv35
	source venv35/bin/activate && \
	cd src/fiona && \
	git fetch --tags && \
	git checkout $(VERSION) && \
	pip install -r requirements-dev.txt && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" pip install -e . && \
	nosetests --exclude test_filter_vsi --exclude test_geopackage && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) PACKAGE_DATA=1 PROJ_LIB=$(PROJ_LIB) GDAL_CONFIG=$(GDAL_CONFIG) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS) $$($(GDAL_CONFIG) --cflags)" LDFLAGS="$$($(GDAL_CONFIG) --libs) $(CFLAGS)" python setup.py sdist bdist_wheel

fiona_sdist: dist fiona_27 fiona_34 fiona_35
	cp src/fiona/dist/*gz dist

fiona_dist: dist fiona_27 fiona_34 fiona_35
	source venv27/bin/activate && \
	parallel delocate-wheel -w src/fiona/delocated --require-archs=intel -v {} ::: src/fiona/dist/*.whl
	parallel mv {} dist/{/.}.macosx_10_9_intel.macosx_10_9_x86_64.macosx_10_10_intel.macosx_10_10_x86_64.whl ::: src/fiona/delocated/*.whl

clean:
	rm -rf dist
	rm -rf src/Fiona
	rm -rf src/rasterio
	rm -rf src/Shapely
	rm -rf venv27
	rm -rf venv34
	rm -rf venv35
