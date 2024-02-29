Instructions for building libevent 2.1.12 on Cirrus
===================================================

These instructions are for building libevent 2.1.12 on Cirrus (SGI ICE XA, Intel Xeon Broadwell (CPU) and Cascade Lake (GPU)) using gcc 10.2.0.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/cirrus-software

LIBEVENT_LABEL=libevent
LIBEVENT_VERSION=2.1.12
LIBEVENT_NAME=${LIBEVENT_LABEL}-${LIBEVENT_VERSION}
LIBEVENT_ROOT=${PRFX}/${LIBEVENT_LABEL}
LIBEVENT_INSTALL=${LIBEVENT_ROOT}/${LIBEVENT_VERSION}
```

Download source code
--------------------

```bash
mkdir -p ${LIBEVENT_ROOT}
cd ${LIBEVENT_ROOT}

git clone https://github.com/${LIBEVENT_LABEL}/${LIBEVENT_LABEL}.git ${LIBEVENT_NAME}
cd ${LIBEVENT_NAME}
git checkout release-${LIBEVENT_VERSION}-stable
```

Build libevent
--------------

```bash
module load gcc/10.2.0
module load autotools/default
module load openssl/3.2.1

./autogen.sh

./configure --prefix=${LIBEVENT_INSTALL}

make -j 8
make -j 8 install
make -j 8 clean
```
