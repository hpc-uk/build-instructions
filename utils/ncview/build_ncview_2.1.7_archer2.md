Instructions for installing Ncview 2.1.7 on ARCHER2
===================================================

These instructions show how to install Ncview 2.1.7 for use on ARCHER2 (HPE Cray EX, AMD Zen2 7742).


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work
NCVIEW_LABEL=ncview
NCVIEW_VERSION=2.1.7
NCVIEW_NAME=${NCVIEW_LABEL}-${NCVIEW_VERSION}
NCVIEW_ARCHIVE=${NCVIEW_NAME}.tar.gz
NCVIEW_BUILD=${PRFX}/${NCVIEW_LABEL}/${NCVIEW_NAME}
NCVIEW_INSTALL=${PRFX}/${NCVIEW_LABEL}/${NCVIEW_VERSION}
UDUNITS_INSTALL=/work/y07/shared/libs/core/udunits/2.2.28

mkdir -p ${PRFX}/${NCVIEW_LABEL}
cd ${PRFX}/${NCVIEW_LABEL}
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.

Note also, that the Ncview build requires the UDUNITS library. The `UDUNITS_INSTALL` variable
is set to a specific path, but if you need to build your own UDUNITS library you can refer to
these [instructions](../../libs/udunits/build_udunits_2.2.28_archer2.md).


Setup soft link to PNG library
------------------------------

```bash
mkdir libpng
cd libpng
# ncview configure insists on "libpng.so"
ln -s /usr/lib64/libpng16.so libpng.so
cd ..


Download the Ncview source code
-------------------------------

```bash
wget ftp://cirrus.ucsd.edu/pub/${NCVIEW_LABEL}/${NCVIEW_ARCHIVE}
tar -xvzf ${NCVIEW_ARCHIVE}
rm ${NCVIEW_ARCHIVE}
```


Build Ncview
------------

```bash
cd ${NCVIEW_NAME}

module -q restore
module -q load PrgEnv-gnu
module -q load cray-hdf5-parallel
module -q load cray-netcdf-hdf5parallel

./configure --with-udunits2_incdir=${UDUNITS_INSTALL}/include \
            --with-udunits2_libdir=${UDUNITS_INSTALL}/lib \
            --with-png_incdir=/usr/include/libpng16 \
            --with-png-libdir=${PRFX}/${NCVIEW_LABEL}/libpng \
            --prefix=${NCVIEW_INSTALL}

make
make install
make clean
```
