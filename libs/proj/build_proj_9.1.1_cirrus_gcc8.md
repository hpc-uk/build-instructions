Instructions for installing PROJ 9.1.1 on Cirrus
================================================

These instructions show how to build PROJ 9.1.1 for use on Cirrus (SGI ICE XA, Intel Xeon E5-2695)
using GCC 8.2.0. PROJ 9.1.1 requires [SQLite 3.40.1](https://github.com/hpc-uk/build-instructions/tree/main/libs/sqlite).


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/mnt/lustre/indy2lfs/sw

PROJ_LABEL=proj
PROJ_VERSION=9.1.1
PROJ_NAME=${PROJ_LABEL}-${PROJ_VERSION}
PROJ_ROOT=${PRFX}/${PROJ_LABEL}
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.
The following instructions assume that an installation of [SQLite 3.40.1](https://github.com/hpc-uk/build-instructions/blob/main/libs/sqlite/build_sqlite_3.40.1_cirrus_gcc8.md) exists directly
off the path indicated by `PRFX`.


Download the PROJ source code
-----------------------------

```bash
mkdir -p ${PROJ_ROOT}
cd ${PROJ_ROOT}

wget https://download.osgeo.org/${PROJ_LABEL}/${PROJ_NAME}.tar.gz
tar -xzf ${PROJ_NAME}.tar.gz
rm ${PROJ_NAME}.tar.gz
```


Setup build environment
-----------------------

```bash
cd ${PROJ_ROOT}/${PROJ_NAME}

module load gcc/8.2.0
module load cmake/3.17.3

rm -rf build
mkdir build
cd build

SQLITE_ROOT=${PRFX}/sqlite/3.40.1
SQLITE_INC_DIR=${SQLITE_ROOT}/include
SQLITE_LIB_DIR=${SQLITE_ROOT}/lib
```


Build PROJ
----------

```bash
cmake .. -DSQLITE3_INCLUDE_DIR=${SQLITE_INC_DIR} -DSQLITE3_LIBRARY=${SQLITE_LIB_DIR}/libsqlite3.so -DCMAKE_INSTALL_PREFIX=${PROJ_ROOT}/${PROJ_VERSION}

cmake --build .
cmake --build . --target install
```
