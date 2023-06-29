Instructions for installing libsndfile 1.0.28 on Cirrus
=======================================================

These instructions show how to build libsndfile 1.0.28 for use on Cirrus (SGI ICE XA, Intel Xeon E5-2695)
using GCC 8.2.0.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/mnt/lustre/indy2lfs/sw

LIBSNDFILE_LABEL=libsndfile
LIBSNDFILE_VERSION=1.0.28
LIBSNDFILE_NAME=${LIBSNDFILE_LABEL}-${LIBSNDFILE_VERSION}
LIBSNDFILE_ROOT=${PRFX}/${LIBSNDFILE_LABEL}
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Download the libsndfile source code
-----------------------------------

```bash
mkdir -p ${LIBSNDFILE_ROOT}
cd ${LIBSNDFILE_ROOT}

wget http://www.mega-nerd.com/${LIBSNDFILE_LABEL}/files/${LIBSNDFILE_NAME}.tar.gz

tar -xzf ${LIBSNDFILE_NAME}.tar.gz
rm ${LIBSNDFILE_NAME}.tar.gz
```


Setup build environment
-----------------------

```bash
cd ${LIBSNDFILE_ROOT}/${LIBSNDFILE_NAME}

module load gcc/8.2.0
```


Build libsndfile
----------------

```bash
./configure --prefix=${LIBSNDFILE_ROOT}/${LIBSNDFILE_VERSION}

make
make install
make clean
```
