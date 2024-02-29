Instructions for installing GDAL 3.6.2 on Cirrus
================================================

These instructions show how to build GDAL 3.6.2 for use on Cirrus (SGI ICE XA, Intel Xeon E5-2695)
using GCC 10.2.0. GDAL 3.6.2 requires [PROJ 9.1.1](https://github.com/hpc-uk/build-instructions/tree/main/libs/proj) and [SQLite 3.40.1](https://github.com/hpc-uk/build-instructions/tree/main/libs/sqlite).


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/cirrus-software

GDAL_LABEL=gdal
GDAL_VERSION=3.6.2
GDAL_NAME=${GDAL_LABEL}-${GDAL_VERSION}
GDAL_ROOT=${PRFX}/${GDAL_LABEL}
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.
The following instructions assume that installations of [PROJ 9.1.1](https://github.com/hpc-uk/build-instructions/blob/main/libs/proj/build_proj_9.1.1_cirrus_gcc10.md) and [SQLite 3.40.1](https://github.com/hpc-uk/build-instructions/blob/main/libs/sqlite/build_sqlite_3.40.1_cirrus_gcc10.md) exist
directly off the path indicated by `PRFX`.


Download the GDAL library source code
-------------------------------------

```bash
mkdir -p ${GDAL_ROOT}
cd ${GDAL_ROOT}

wget https://github.com/OSGeo/${GDAL_LABEL}/archive/refs/tags/v${GDAL_VERSION}.tar.gz
tar -xzf v${GDAL_VERSION}.tar.gz
rm v${GDAL_VERSION}.tar.gz
```


Setup build environment
-----------------------

```bash
cd ${GDAL_ROOT}/${GDAL_NAME}

rm -rf build
mkdir build
cd build

module load cmake/3.25.2
module load expat/2.6.0
module load zlib/1.3.1
module load bison/3.8.2
module load python/3.9.13
module load gcc/10.2.0

SQLITE_ROOT=${PRFX}/sqlite/3.40.1
SQLITE_INC_DIR=${SQLITE_ROOT}/include
SQLITE_LIB_DIR=${SQLITE_ROOT}/lib

PROJ_ROOT=${PRFX}/proj/9.1.1
PROJ_INC_DIR=${PROJ_ROOT}/include
PROJ_LIB_DIR=${PROJ_ROOT}/lib64
```


Build GDAL
----------

```bash
cmake -DSQLITE3_INCLUDE_DIR=${SQLITE_INC_DIR} -DSQLITE3_LIBRARY=${SQLITE_LIB_DIR}/libsqlite3.so \
      -DPROJ_INCLUDE_DIR=${PROJ_INC_DIR} -DPROJ_LIBRARY=${PROJ_LIB_DIR}/libproj.so \
      -DPython_ROOT=${MINICONDA3_BIN_PATH} \
      -DCMAKE_INSTALL_PREFIX=${GDAL_ROOT}/${GDAL_VERSION}-gcc \
      -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -DCMAKE_BUILD_TYPE=Release \
      ..

cmake --build .
cmake --build . --target install
```
