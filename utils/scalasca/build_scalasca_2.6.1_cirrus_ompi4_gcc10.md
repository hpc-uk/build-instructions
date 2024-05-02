Instructions for building Scalasca 2.6.1 on Cirrus
==================================================

These instructions are for building Score-P 2.6.2 on Cirrus (SGI ICE XA, Intel Xeon Broadwell (CPU) and Cascade Lake (GPU))
using OpenMPI 4.1.6, CUDA 11.6 and GCC 10.2.0.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/cirrus-software

SCALASCA_LABEL=scalasca
SCALASCA_VERSION=2.6.1
SCALASCA_VER=`echo ${SCALASCA_VERSION} | cut -d. -f1-2`
SCALASCA_NAME=${SCALASCA_LABEL}-${SCALASCA_VERSION}
SCALASCA_ROOT=${PRFX}/${SCALASCA_LABEL}
SCALASCA_INSTALL=${SCALASCA_ROOT}/${SCALASCA_VERSION}
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Download source code
--------------------

```bash
mkdir -p ${SCALASCA_ROOT}
cd ${SCALASCA_ROOT}

wget https://apps.fz-juelich.de/${SCALASCA_LABEL}/releases/${SCALASCA_LABEL}/${SCALASCA_VER}/dist/${SCALASCA_NAME}.tar.gz

tar -xvzf ${SCALASCA_NAME}.tar.gz
rm ${SCALASCA_NAME}.tar.gz
```


Build and install for CPU
-------------------------

```bash
module -s load openmpi/4.1.6

cd ${SCALASCA_ROOT}/${SCALASCA_NAME}

./configure --prefix=${SCALASCA_INSTALL}-ompi4

make -j 8
make -j 8 install
make -j 8 clean
```


Build and install for GPU
-------------------------

```bash
module -s load nvidia/nvhpc-nompi/22.2
module -s load openmpi/4.1.6-cuda-11.6

cd ${SCALASCA_ROOT}/${SCALASCA_NAME}

./configure --prefix=${SCALASCA_INSTALL}-ompi4-cuda116

make -j 8
make -j 8 install
make -j 8 clean
```
