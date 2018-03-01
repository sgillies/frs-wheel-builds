import os.path

def staticgeos(options, buildout, environment):
    optsfile = os.path.join(options['compile-directory'], 'gdal-2.2.3', 'GDALmake.opt')
    geosdir = os.path.join(buildout['buildout']['directory'], 'parts', 'geos')
    with open(optsfile) as src:
        options = src.read()
    repls = '{0}/lib/libgeos.a {0}/lib/libgeos_c.a'.format(geosdir)
    options = options.replace('-lgeos_c', repls)
    with open(optsfile, 'w') as dst:
        dst.write(options)
