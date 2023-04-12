Instructions for installing GDAL 3.6.2 on Cirrus
================================================

These instructions show how to build GDAL 3.6.2 for use on Cirrus (SGI ICE XA, Intel Xeon E5-2695)
using GCC 8.2.0. GDAL 3.6.2 requires [PROJ 9.1.1](https://github.com/hpc-uk/build-instructions/tree/main/libs/proj) and [SQLite 3.40.1](https://github.com/hpc-uk/build-instructions/tree/main/libs/sqlite).


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/mnt/lustre/indy2lfs/sw

GDAL_LABEL=gdal
GDAL_VERSION=3.6.2
GDAL_NAME=${GDAL_LABEL}-${GDAL_VERSION}
GDAL_ROOT=${PRFX}/${GDAL_LABEL}
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.
The following instructions assume that installations of [PROJ 9.1.1](https://github.com/hpc-uk/build-instructions/blob/main/libs/proj/build_proj_9.1.1_cirrus_gcc8.md) and [SQLite 3.40.1](https://github.com/hpc-uk/build-instructions/blob/main/libs/sqlite/build_sqlite_3.40.1_cirrus_gcc8.md) exist
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

module load gcc/8.2.0
module load cmake/3.17.3
module load expat/2.2.9
module load zlib/1.2.11
module load bison/3.6.4

SQLITE_ROOT=${PRFX}/sqlite/3.40.1
SQLITE_INC_DIR=${SQLITE_ROOT}/include
SQLITE_LIB_DIR=${SQLITE_ROOT}/lib

PROJ_ROOT=${PRFX}/proj/9.1.1
PROJ_INC_DIR=${PROJ_ROOT}/include
PROJ_LIB_DIR=${PROJ_ROOT}/lib64

DOXYGEN_ROOT=${PRFX}/doxygen/1.8.14-gcc6
DOXYGEN_BIN_DIR=${DOXYGEN_ROOT}/bin
```


Build GDAL
----------

```bash
cmake -DSQLITE3_INCLUDE_DIR=${SQLITE_INC_DIR} -DSQLITE3_LIBRARY=${SQLITE_LIB_DIR}/libsqlite3.so \
      -DPROJ_INCLUDE_DIR=${PROJ_INC_DIR} -DPROJ_LIBRARY=${PROJ_LIB_DIR}/libproj.so \
      -DDOXYGEN_EXECUTABLE=${DOXYGEN_BIN_DIR}/doxygen \
      -DPython_ROOT=${PRFX}/anaconda/anaconda3-2021.11/bin \
      -DCMAKE_INSTALL_PREFIX=${GDAL_ROOT}/${GDAL_VERSION}-gcc \
      -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -DCMAKE_BUILD_TYPE=Release \
      ..

cmake --build .
cmake --build . --target install
```
