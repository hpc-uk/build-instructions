Instructions for installing Expat 2.6.0 on Cirrus
=================================================

These instructions show how to build Expat 2.6.0 for use on Cirrus (SGI ICE XA, Intel Xeon E5-2695)
using GCC 10.2.0.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/cirrus-software

EXPAT_LABEL=expat
EXPAT_VERSION=2.6.0
EXPAT_NAME=${EXPAT_LABEL}-${EXPAT_VERSION}
EXPAT_ROOT=${PRFX}/${EXPAT_LABEL}
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Download the Expat source code
------------------------------

```bash
mkdir -p ${EXPAT_ROOT}
cd ${EXPAT_ROOT}

git clone https://github.com/libexpat/libexpat.git ${EXPAT_NAME}
cd ${EXPAT_NAME}
git checkout R_${EXPAT_VERSION/./_}
```


Build Expat
-----------

```bash
module load autotools
module load gcc/10.2.0

cd ${EXPAT_ROOT}/${EXPAT_NAME}/${EXPAT_LABEL}

./buildconf.sh

./configure --prefix=${EXPAT_ROOT}/${EXPAT_VERSION}

make
make install
make clean
```
