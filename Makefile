SHELL = /bin/bash

LAST_TAG_COMMIT = $$(git rev-list --tags --max-count=1)
VERSION = $$(git describe --tags $(LAST_TAG_COMMIT) )

MACOSX_DEPLOYMENT_TARGET = 10.6
GEOS_CONFIG = "../../parts/libgeos/bin/geos-config"

shapely: src/Shapely/fixed_wheels/27 src/Shapely/fixed_wheels/34

venv27:
	virtualenv -p python2.7 venv27

venv34:
	virtualenv -p python3.4 venv34

src/Shapely/.git:
	git clone https://github.com/Toblerity/Shapely.git src/Shapely

src/Shapely/fixed_wheels/27: src/Shapely/.git venv27
	source venv27/bin/activate && \
	cd src/Shapely && \
	git fetch --tags && \
	git checkout $(VERSION) && \
	pip install -r requirements-dev.txt && \
	pip install wheel delocate && \
	touch shapely/speedups/*.pyx && \
	touch shapely/vectorized/*.pyx && \
	mkdir -p wheels/27 && mkdir -p fixed_wheels/27 && \
	rm -rf build && rm -rf wheels/27/$(VERSION) && rm -rf fixed_wheels/27/$(VERSION) && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) CFLAGS="$$($(GEOS_CONFIG) --cflags)" LDFLAGS="$$($(GEOS_CONFIG) --libs)" python setup.py bdist_wheel -d wheels/27/$(VERSION) && \
	delocate-wheel -w fixed_wheels/27/$(VERSION) --require-archs=intel -v wheels/27/$(VERSION)/Shapely*.whl && \
	parallel mv {} {.}.macosx_10_9_intel.macosx_10_9_x86_64.macosx_10_10_intel.macosx_10_10_x86_64.whl ::: fixed_wheels/27/$(VERSION)/Shapely*.whl

src/Shapely/fixed_wheels/34: src/Shapely/.git venv34
	source venv34/bin/activate && \
	cd src/Shapely && \
	git fetch --tags && \
	git checkout $(VERSION) && \
	pip install -r requirements-dev.txt && \
	pip install wheel delocate && \
	touch shapely/speedups/*.pyx && \
	touch shapely/vectorized/*.pyx && \
	mkdir -p wheels/34 && mkdir -p fixed_wheels/34 && \
	rm -rf build && rm -rf wheels/34/$(VERSION) && rm -rf fixed_wheels/34/$(VERSION) && \
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) CFLAGS="$$($(GEOS_CONFIG) --cflags)" LDFLAGS="$$($(GEOS_CONFIG) --libs)" python setup.py bdist_wheel -d wheels/34/$(VERSION) && \
	delocate-wheel -w fixed_wheels/34/$(VERSION) --require-archs=intel -v wheels/34/$(VERSION)/Shapely*.whl && \
	parallel mv {} {.}.macosx_10_9_intel.macosx_10_9_x86_64.macosx_10_10_intel.macosx_10_10_x86_64.whl ::: fixed_wheels/34/$(VERSION)/Shapely*.whl

clean:
	rm -rf src/Shapely
	rm -rf venv27
	rm -rf venv34
