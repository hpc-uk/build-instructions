Instructions for installing GSL 2.6.0 on Cirrus
===============================================

These instructions show how to install GSL 2.6.0 for use on Cirrus (SGI ICE XA, Intel Xeon E5-2695).


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/lustre/sw
GSL_LABEL=gsl
GSL_VERSION=2.6
GSL_NAME=${GSL_LABEL}-${GSL_VERSION}
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Download the GSL library source code
------------------------------------

```bash
mkdir -p ${PRFX}/${GSL_LABEL}
cd ${PRFX}/${GSL_LABEL}

rm -rf ${GSL_NAME}
wget http://mirror.koddos.net/gnu/${GSL_LABEL}/${GSL_NAME}.tar.gz
tar -xzf ${GSL_NAME}.tar.gz
rm ${GSL_NAME}.tar.gz
cd ${GSL_NAME}
```


Build the GSL library
---------------------

```bash
module load gcc/6.3.0

./configure CC=gcc --prefix=${PRFX}/${GSL_LABEL}/${GSL_VERSION}
make
make check
make install
make clean
```
