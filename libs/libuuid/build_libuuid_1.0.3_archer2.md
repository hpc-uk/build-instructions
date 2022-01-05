Instructions for installing libuuid 1.0.3 on ARCHER2
====================================================

These instructions show how to install libuuid 1.0.3 for use on ARCHER2 (HPE Cray EX, AMD Zen2 7742).


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work
LIBUUID_LABEL=libuuid
LIBUUID_VERSION=1.0.3
LIBUUID_NAME=${LIBUUID_LABEL}-${LIBUUID_VERSION}
LIBUUID_ROOT=${PRFX}/${LIBUUID_LABEL}
LIBUUID_INSTALL=${LIBUUID_ROOT}/${LIBUUID_VERSION}

mkdir -p ${LIBUUID_ROOT}
cd ${LIBUUID_ROOT}
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.


Download the libuuid source code
--------------------------------

```bash
wget http://sourceforge.net/projects/${LIBUUID_LABEL}/files/${LIBUUID_NAME}.tar.gz
tar -xvzf ${LIBUUID_NAME}.tar.gz
rm ${LIBUUID_NAME}.tar.gz
```


Build libuuid
-------------

```bash
cd ${LIBUUID_NAME}

module -q restore
module -q load cpe/21.09
module -q load PrgEnv-gnu

export LD_LIBRARY_PATH=${CRAY_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH}

./configure CC=cc --prefix=${LIBUUID_INSTALL}

make
make install
make clean
```
