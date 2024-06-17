Instructions for building UCX 1.16.0 on Cirrus
==============================================

These instructions are for building UCX 1.16.0 on Cirrus (SGI ICE XA, Intel Xeon Broadwell (CPU) and Cascade Lake (GPU)) using gcc 10.2.0.

The instructions cover builds for both the CPU and GPU nodes.
The GPU build instructions cover CUDA 12.4.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/cirrus-software
UCX_LABEL=ucx
UCX_VERSION=1.16.0
UCX_NAME=${UCX_LABEL}-${UCX_VERSION}
UCX_ROOT=${PRFX}/${UCX_LABEL}

KNEM_ROOT=/opt/knem-1.1.4.90mlnx2

mkdir -p ${UCX_ROOT}
cd ${UCX_ROOT}

git clone https://github.com/openucx/${UCX_LABEL}.git ${UCX_NAME}
cd ${UCX_NAME}
git checkout v${UCX_VERSION}

module load libtool/2.4.7

./autogen.sh

module load zlib/1.3.1
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Build and install UCX for CPU
-----------------------------

```bash
cd ${UCX_ROOT}/${UCX_NAME}

module load gcc/10.2.0

./configure CC=gcc CXX=g++ FC=gfortran \
  --with-knem=${KNEM_ROOT} \
  --enable-mt --prefix=${PRFX}/${UCX_LABEL}/${UCX_VERSION}

make -j 8
make -j 8 install
make -j 8 clean
```


Build and install UCX for GPU (CUDA 12.4)
-----------------------------------------

```bash
cd ${UCX_ROOT}/${UCX_NAME}

module load gcc/10.2.0
module load nvidia/nvhpc-nompi/24.5

CUDA_VERSION=12.4

./configure CC=gcc CXX=g++ FC=gfortran \
  --with-knem=${KNEM_ROOT} \
  --with-cuda=${NVHPC_ROOT}/cuda/${CUDA_VERSION} \
  --with-mlx5-dv --enable-mt \
  --prefix=${PRFX}/${UCX_LABEL}/${UCX_VERSION}-cuda-${CUDA_VERSION}

make -j 8
make -j 8 install
make -j 8 clean
```
