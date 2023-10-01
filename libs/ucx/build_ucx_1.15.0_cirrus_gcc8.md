Instructions for building UCX 1.15.0 on Cirrus
==============================================

These instructions are for building UCX 1.15.0 on Cirrus (SGI ICE XA, Intel Xeon Broadwell (CPU) and Cascade Lake (GPU)) using gcc 8.2.0.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work # e.g., /mnt/lustre/indy2lfs/sw
UCX_LABEL=ucx
UCX_VERSION=1.15.0
UCX_NAME=${UCX_LABEL}-${UCX_VERSION}
UCX_ROOT=${PRFX}/${UCX_LABEL}

KNEM_ROOT=/opt/knem-1.1.4.90mlnx1

mkdir -p ${UCX_ROOT}
cd ${UCX_ROOT}

git clone https://github.com/openucx/${UCX_LABEL}.git ${UCX_NAME}
cd ${UCX_NAME}
git checkout v${UCX_VERSION}-rc4

module load libtool/2.4.6

./autogen.sh

module load zlib/1.2.11
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Build and install UCX for CPU
-----------------------------

```bash
module load gcc/8.2.0

./configure CC=gcc CXX=g++ FC=gfortran \
  --with-knem=${KNEM_ROOT} \
  --enable-mt --prefix=${PRFX}/${UCX_LABEL}/${UCX_VERSION}

make -j 8
make -j 8 install
make -j 8 clean
```


Build and install UCX for GPU (CUDA 11.6)
-----------------------------------------

```bash
module load nvidia/nvhpc-nompi/22.2

CUDA_VERSION=11.6

./configure CC=gcc CXX=g++ FC=gfortran \
  --with-knem=${KNEM_ROOT} \
  --with-cuda=${NVHPC_ROOT}/cuda/${CUDA_VERSION} \
  --with-mlx5-dv --enable-mt \
  --prefix=${PRFX}/${UCX_LABEL}/${UCX_VERSION}-cuda-${CUDA_VERSION}

make -j 8
make -j 8 install
make -j 8 clean
```
