Instructions for installing SQLite 3.40.1 on Cirrus
===================================================

These instructions show how to build SQLite 3.40.1 for use on Cirrus (SGI ICE XA, Intel Xeon E5-2695)
using GCC 8.2.0.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/mnt/lustre/indy2lfs/sw

SQLITE_LABEL=sqlite
SQLITE_VERSION=3.40.1
SQLITE_VERSION_RAW=3400100
SQLITE_NAME=${SQLITE_LABEL}-${SQLITE_VERSION}
SQLITE_ROOT=${PRFX}/${SQLITE_LABEL}
SQLITE_ARCHIVE=${SQLITE_LABEL}-autoconf-${SQLITE_VERSION_RAW}
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Download the SQLite source code
-------------------------------

```bash
mkdir -p ${SQLITE_ROOT}
cd ${SQLITE_ROOT}

wget https://www.sqlite.org/2022/${SQLITE_ARCHIVE}.tar.gz
tar -xzf ${SQLITE_ARCHIVE}.tar.gz
rm ${SQLITE_ARCHIVE}.tar.gz
mv ${SQLITE_ARCHIVE} ${SQLITE_NAME}
```


Setup build environment
-----------------------

```bash
cd ${SQLITE_ROOT}/${SQLITE_NAME}

module load gcc/8.2.0
```


Build SQLite
------------

```bash
./configure --prefix=${SQLITE_ROOT}/${SQLITE_VERSION}

make
make install
make clean
```
