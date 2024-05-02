Instructions for building Score-P 8.4 on Cirrus
===============================================

These instructions are for building Score-P 8.4 on Cirrus (SGI ICE XA, Intel Xeon Broadwell (CPU) and Cascade Lake (GPU))
using OpenMPI 4.1.6, CUDA 11.6, GCC 10.2.0 and GNU Binutils 2.42.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/cirrus-software

SCOREP_LABEL=scorep
SCOREP_VERSION=8.4
SCOREP_NAME=${SCOREP_LABEL}-${SCOREP_VERSION}
SCOREP_ROOT=${PRFX}/${SCOREP_LABEL}
SCOREP_INSTALL=${SCOREP_ROOT}/${SCOREP_VERSION}

LIBPMI2_ROOT=/work/y07/shared/cirrus-software/pmi2

module -s load binutils/2.42
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Download source code
--------------------

```bash
mkdir -p ${SCOREP_ROOT}
cd ${SCOREP_ROOT}

wget https://perftools.pages.jsc.fz-juelich.de/cicd/${SCOREP_LABEL}/tags/${SCOREP_NAME}/${SCOREP_NAME}.tar.gz

tar -xvzf ${SCOREP_NAME}.tar.gz
rm ${SCOREP_NAME}.tar.gz
```


Build and install for CPU
-------------------------

```bash
module -s load openmpi/4.1.6

cd ${SCOREP_ROOT}/${SCOREP_NAME}

rm -rf _build_cpu
mkdir _build_cpu
cd _build_cpu

../configure --with-libpmi=${LIBPMI2_ROOT} \
             --prefix=${SCOREP_INSTALL}-ompi4

make -j 8
make -j 8 install
make -j 8 clean
```


Build and install for GPU
-------------------------

```bash
module -s load nvidia/nvhpc-nompi/22.2
module -s load openmpi/4.1.6-cuda-11.6

LIBCUDART_ROOT=${NVHPC_ROOT}/cuda/11.6
LIBCUPTI_ROOT=${LIBCUDART_ROOT}/extras/CUPTI

cd ${SCOREP_ROOT}/${SCOREP_NAME}

rm -rf _build_gpu
mkdir _build_gpu
cd _build_gpu

../configure --with-libpmi=${LIBPMI2_ROOT} \
             --enable-cuda \
             --with-libcudart=${LIBCUDART_ROOT} \
             --with-libcudart-include=${LIBCUDART_ROOT}/include \
             --with-libcudart-lib=${LIBCUDART_ROOT}/lib64 \
             --with-libcupti=${LIBCUPTI_ROOT} \
             --with-libcupti-include=${LIBCUPTI_ROOT}/include \
             --with-libcupti-lib=${LIBCUPTI_ROOT}/lib64 \
             --with-libcuda-lib=${LIBCUDART_ROOT}/lib64/stubs \
             --with-libnvidia-ml-lib=${LIBCUDART_ROOT}/lib64/stubs \
             --prefix=${SCOREP_INSTALL}-ompi4-cuda116

make -j 8
make -j 8 install
make -j 8 clean
```
