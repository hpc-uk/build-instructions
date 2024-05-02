Instructions for building GNU Binutils 2.42 on Cirrus
=====================================================

These instructions are for building GNU Binutils 2.42 on Cirrus (SGI ICE XA, Intel Xeon Broadwell (CPU) and Cascade Lake (GPU)) using gcc 10.2.0.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/cirrus-software

BINUTILS_LABEL=binutils
BINUTILS_VERSION=2.42
BINUTILS_NAME=${BINUTILS_LABEL}-${BINUTILS_VERSION}
BINUTILS_ROOT=${PRFX}/${BINUTILS_LABEL}
BINUTILS_INSTALL=${BINUTILS_ROOT}/${BINUTILS_VERSION}
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Download source code
--------------------

```bash
mkdir -p ${BINUTILS_ROOT}
cd ${BINUTILS_ROOT}

wget https://ftp.gnu.org/gnu/${BINUTILS_LABEL}/${BINUTILS_NAME}.tar.gz

tar -xvzf ${BINUTILS_NAME}.tar.gz
rm ${BINUTILS_NAME}.tar.gz
```


Build and install
-----------------

```bash
cd ${BINUTILS_NAME}

module -s load gcc/10.2.0
module -s load gmp/6.3.0-gcc
module -s load mpc/1.1.0
module -s load mpfr/4.2.1-gcc

CIRRUS_SW_ROOT=/work/y07/shared/cirrus-software

./configure --with-gmp=${CIRRUS_SW_ROOT}/gmp/6.3.0-gcc \
            --with-mpc=${CIRRUS_SW_ROOT}/mpc/1.1.0 \
            --with-mpfr=${CIRRUS_SW_ROOT}/mpfr/4.2.1-gcc \
            --enable-shared --enable-libiberty \
            --prefix=${BINUTILS_INSTALL}-gcc

make -j 8
make -j 8 install
```

Do not run `make clean` as this will delete library files such as `libiberty.a`, which may be needed
to build other software packages, e.g., [Score-P](../../utils/scorep).
