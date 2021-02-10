Instructions for building UCX 1.9.0 on Cirrus
=============================================

These instructions are for building UCX 1.9.0 on Cirrus (SGI ICE XA, Intel Xeon Broadwell (CPU) and Cascade Lake (GPU)) using gcc 8.2.0.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work
UCX_LABEL=ucx
UCX_VERSION=1.9.0
UCX_NAME=${UCX_LABEL}-${UCX_VERSION}

mkdir -p ${PRFX}/${UCX_LABEL}
cd ${PRFX}/${UCX_LABEL}

wget https://github.com/openucx/${UCX_LABEL}/archive/v${UCX_VERSION}.tar.gz
tar xzf v${UCX_VERSION}.tar.gz
rm v${UCX_VERSION}.tar.gz
cd ${UCX_NAME}
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Build and install UCX for CPU
-----------------------------

```bash
module load libtool/2.4.6
module load autotools/default

./autogen.sh

module load zlib/1.2.11
module load gcc/8.2.0

./configure CC=gcc CXX=g++ FC=gfortran \
  --prefix=/lustre/sw/${UCX_LABEL}/${UCX_VERSION}

make
make install
make clean
```


Build and install UCX for GPU (CUDA 10.1)
-----------------------------------------

```bash
module unload gcc/8.2.0
module load nvidia/cuda-10.1
module load nvidia/mathlibs-10.1
module swap gcc gcc/8.2.0

./configure CC=gcc CXX=g++ FC=gfortran \
  LDFLAGS="-L/lustre/sw/nvidia/hpcsdk/Linux_x86_64/20.9/cuda/11.0/targets/x86_64-linux/lib/stubs" \
  --with-cuda=/lustre/sw/nvidia/hpcsdk/Linux_x86_64/cuda/10.1 \
  --prefix=/lustre/sw/${UCX_LABEL}/${UCX_VERSION}-cuda-10.1

make
make install
make clean
```


Build and install UCX for GPU (CUDA 10.2)
-----------------------------------------

```bash
module unload gcc/8.2.0
module swap nvidia/cuda-10.1 nvidia/cuda-10.2
module swap nvidia/mathlibs-10.1 nvidia/mathlibs-10.2  
module swap gcc gcc/8.2.0

./configure CC=gcc CXX=g++ FC=gfortran \
  LDFLAGS="-L/lustre/sw/nvidia/hpcsdk/Linux_x86_64/20.9/cuda/11.0/targets/x86_64-linux/lib/stubs" \
  --with-cuda=/lustre/sw/nvidia/hpcsdk/Linux_x86_64/cuda/10.2 \
  --prefix=/lustre/sw/${UCX_LABEL}/${UCX_VERSION}-cuda-10.2

make
make install
make clean
```
