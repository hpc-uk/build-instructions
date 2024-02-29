Instructions for building OpenSSL 3.2.1 on Cirrus
=================================================

These instructions are for building OpenSSL 3.2.1 on Cirrus (SGI ICE XA, Intel Xeon Broadwell (CPU) and Cascade Lake (GPU)) using gcc 10.2.0.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/cirrus-software

OPENSSL_LABEL=openssl
OPENSSL_VERSION=3.2.1
OPENSSL_NAME=${OPENSSL_LABEL}-${OPENSSL_VERSION}
OPENSSL_ROOT=${PRFX}/${OPENSSL_LABEL}
OPENSSL_INSTALL=${OPENSSL_ROOT}/${OPENSSL_VERSION}
```

Download source code
--------------------

```bash
mkdir -p ${OPENSSL_ROOT}
cd ${OPENSSL_ROOT}

wget https://www.openssl.org/source/${OPENSSL_NAME}.tar.gz
tar -xvzf ${OPENSSL_NAME}.tar.gz
rm ${OPENSSL_NAME}.tar.gz
cd ${OPENSSL_NAME}
```

Build OpenSSL
-------------

```bash
module load gcc/10.2.0

./config --prefix=${OPENSSL_INSTALL}

make -j 8
make -j 8 install
make -j 8 clean
```
