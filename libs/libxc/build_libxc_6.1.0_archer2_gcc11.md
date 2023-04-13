Instructions for installing libxc 6.1.0 on ARCHER2
==================================================

These instructions show how to build libxc 6.1.0 for use on ARCHER2 (HPE Cray EX, AMD Zen2 7742)
using GCC 11.2.0.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=${HOME/home/work}/libs

LIBXC_LABEL=libxc
LIBXC_VERSION=6.1.0
LIBXC_NAME=${LIBXC_LABEL}-${LIBXC_VERSION}
LIBXC_ROOT=${PRFX}/${LIBXC_LABEL}
LIBXC_INSTALL=${LIBXC_ROOT}/${LIBXC_VERSION}
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.


Download the libxc source code
------------------------------

```bash
mkdir -p ${LIBXC_ROOT}
cd ${LIBXC_ROOT}

rm -rf ${LIBXC_NAME}
wget -q https://gitlab.com/${LIBXC_LABEL}/${LIBXC_LABEL}/-/archive/${LIBXC_VERSION}/${LIBXC_NAME}.tar.gz
tar zxf ${LIBXC_NAME}.tar.gz
rm ${LIBXC_NAME}.tar.gz
cd ${LIBXC_NAME}
```


Setup build environment
-----------------------

```bash
module -q restore
module -q load cpe/21.09
module -q load PrgEnv-gnu
```


Build libxc
-----------

```bash
cd ${LIBXC_ROOT}/${LIBXC_NAME}

autoreconf -i

CC=cc CXX=CC FC=ftn ./configure --enable-shared --disable-fortran --prefix=${LIBXC_INSTALL}

make -j 8
make -j 8 install
make -j 8 clean
```


Create libxc environment file
-----------------------------

```bash
echo -e "export LIBXC_ROOT=${LIBXC_INSTALL}\n" > ${LIBXC_INSTALL}/env.sh
echo -e "export PATH=\${LIBXC_ROOT}/bin:\${PATH}" >> ${LIBXC_INSTALL}/env.sh
echo -e "export CPATH=\${LIBXC_ROOT}/include:\${CPATH}" >> ${LIBXC_INSTALL}/env.sh
echo -e "export LIBRARY_PATH=\${LIBXC_ROOT}/lib:\${LIBRARY_PATH}" >> ${LIBXC_INSTALL}/env.sh
echo -e "export LD_LIBRARY_PATH=\${LIBXC_ROOT}/lib:\${LD_LIBRARY_PATH}" >> ${LIBXC_INSTALL}/env.sh

chmod 700 ${LIBXC_INSTALL}/env.sh
```
