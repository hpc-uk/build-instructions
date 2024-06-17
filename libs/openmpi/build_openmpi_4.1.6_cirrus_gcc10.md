Instructions for building OpenMPI 4.1.6 on Cirrus
=================================================

These instructions are for building OpenMPI 4.1.6 on Cirrus (SGI ICE XA, Intel Xeon Broadwell (CPU) and Cascade Lake (GPU)) using gcc 10.2.0.

The instructions cover builds for both the CPU and GPU nodes.
The GPU build instructions cover CUDA 11.6, 11.8 and 12.4 with and without nvfortran.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/cirrus-software
OPENMPI_LABEL=openmpi
OPENMPI_VERSION=4.1.6
OPENMPI_VERSION_MAJOR=`echo ${OPENMPI_VERSION} | cut -d'.' -f1-2`
OPENMPI_NAME=${OPENMPI_LABEL}-${OPENMPI_VERSION}
OPENMPI_ROOT=${PRFX}/${OPENMPI_LABEL}

LIBEVENT_VERSION=2.1.12

mkdir -p ${OPENMPI_ROOT}
cd ${OPENMPI_ROOT}

wget https://download.open-mpi.org/release/open-mpi/v${OPENMPI_VERSION_MAJOR}/${OPENMPI_NAME}.tar.gz
tar xzf ${OPENMPI_NAME}.tar.gz
rm ${OPENMPI_NAME}.tar.gz
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Build and install OpenMPI for CPU
---------------------------------

```bash
cd ${OPENMPI_ROOT}/${OPENMPI_NAME}

module load zlib/1.3.1
module load gcc/10.2.0

KNEM_ROOT=/opt/knem-1.1.4.90mlnx1

UCX_VERSION=1.15.0

./configure CC=gcc CXX=g++ FC=gfortran \
  CFLAGS="-I${PRFX}/pmi2/include" \
  LDFLAGS="-L${PRFX}/pmi2/lib" \
  --enable-mpi1-compatibility --enable-mpi-fortran \
  --enable-mpi-interface-warning --enable-mpirun-prefix-by-default \
  --with-slurm \
  --with-knem=${KNEM_ROOT} \
  --with-ucx=${PRFX}/ucx/${UCX_VERSION} \
  --with-pmi=${PRFX}/pmi2 --with-pmi-libdir=${PRFX}/pmi2/lib \
  --with-libevent=${PRFX}/libevent/${LIBEVENT_VERSION} \
  --prefix=${PRFX}/${OPENMPI_LABEL}/${OPENMPI_VERSION}

make -j 8
make -j 8 install
make -j 8 clean
```


Build and install OpenMPI for GPU (CUDA 11.6)
---------------------------------------------

```bash
cd ${OPENMPI_ROOT}/${OPENMPI_NAME}

module load zlib/1.3.1
module load gcc/10.2.0
module load nvidia/nvhpc-nompi/22.2

KNEM_ROOT=/opt/knem-1.1.4.90mlnx1

UCX_VERSION=1.15.0
CUDA_VERSION=11.6

./configure CC=gcc CXX=g++ FC=gfortran \
  CFLAGS="-I${PRFX}/pmi2/include" \
  LDFLAGS="-L${PRFX}/pmi2/lib" \
  --enable-mpi1-compatibility --enable-mpi-fortran \
  --enable-mpi-interface-warning --enable-mpirun-prefix-by-default \
  --with-slurm \
  --with-knem=${KNEM_ROOT} \
  --with-ucx=${PRFX}/ucx/${UCX_VERSION}-cuda-${CUDA_VERSION} \
  --with-pmi=${PRFX}/pmi2 --with-pmi-libdir=${PRFX}/pmi2/lib \
  --with-cuda=${NVHPC_ROOT}/cuda/${CUDA_VERSION} \
  --with-libevent=${PRFX}/libevent/${LIBEVENT_VERSION} \
  --prefix=${PRFX}/${OPENMPI_LABEL}/${OPENMPI_VERSION}-cuda-${CUDA_VERSION}

make -j 8
make -j 8 install
make -j 8 clean
```


Build and install OpenMPI for GPU (CUDA 11.6) with nvfortran
------------------------------------------------------------

```bash
cd ${OPENMPI_ROOT}/${OPENMPI_NAME}

module load zlib/1.3.1
module load gcc/10.2.0
module load nvidia/nvhpc-nompi/22.2

KNEM_ROOT=/opt/knem-1.1.4.90mlnx1

UCX_VERSION=1.15.0
CUDA_VERSION=11.6

./configure CC=gcc CXX=g++ FC=nvfortran \
  CFLAGS="-I${PRFX}/pmi2/include" \
  FCFLAGS="-fPIC" \
  LDFLAGS="-L${PRFX}/pmi2/lib -fPIC" \
  --enable-mpi1-compatibility --enable-mpi-fortran \
  --enable-mpi-interface-warning --enable-mpirun-prefix-by-default \
  --with-slurm \
  --with-knem=${KNEM_ROOT} \
  --with-ucx=${PRFX}/ucx/${UCX_VERSION}-cuda-${CUDA_VERSION} \
  --with-pmi=${PRFX}/pmi2 --with-pmi-libdir=${PRFX}/pmi2/lib \
  --with-cuda=${NVHPC_ROOT}/cuda/${CUDA_VERSION} \
  --with-libevent=${PRFX}/libevent/${LIBEVENT_VERSION} \
  --prefix=${PRFX}/${OPENMPI_LABEL}/${OPENMPI_VERSION}-cuda-${CUDA_VERSION}-nvfortran

make -j 8
make -j 8 install
make -j 8 clean
```


Build and install OpenMPI for GPU (CUDA 11.8)
---------------------------------------------

```bash
cd ${OPENMPI_ROOT}/${OPENMPI_NAME}

module load zlib/1.3.1
module load gcc/10.2.0
module load nvidia/nvhpc-nompi/22.11

KNEM_ROOT=/opt/knem-1.1.4.90mlnx1

UCX_VERSION=1.15.0
CUDA_VERSION=11.8

./configure CC=gcc CXX=g++ FC=gfortran \
  CFLAGS="-I${PRFX}/pmi2/include" \
  LDFLAGS="-L${PRFX}/pmi2/lib" \
  --enable-mpi1-compatibility --enable-mpi-fortran \
  --enable-mpi-interface-warning --enable-mpirun-prefix-by-default \
  --with-slurm \
  --with-knem=${KNEM_ROOT} \
  --with-ucx=${PRFX}/ucx/${UCX_VERSION}-cuda-${CUDA_VERSION} \
  --with-pmi=${PRFX}/pmi2 --with-pmi-libdir=${PRFX}/pmi2/lib \
  --with-cuda=${NVHPC_ROOT}/cuda/${CUDA_VERSION} \
  --with-libevent=${PRFX}/libevent/${LIBEVENT_VERSION} \
  --prefix=${PRFX}/${OPENMPI_LABEL}/${OPENMPI_VERSION}-cuda-${CUDA_VERSION}

make -j 8
make -j 8 install
make -j 8 clean
```


Build and install OpenMPI for GPU (CUDA 11.8) with nvfortran
------------------------------------------------------------

```bash
cd ${OPENMPI_ROOT}/${OPENMPI_NAME}

module load zlib/1.3.1
module load gcc/10.2.0
module load nvidia/nvhpc-nompi/22.11

KNEM_ROOT=/opt/knem-1.1.4.90mlnx1

UCX_VERSION=1.15.0
CUDA_VERSION=11.8

./configure CC=gcc CXX=g++ FC=nvfortran \
  CFLAGS="-I${PRFX}/pmi2/include" \
  FCFLAGS="-fPIC" \
  LDFLAGS="-L${PRFX}/pmi2/lib -fPIC" \
  --enable-mpi1-compatibility --enable-mpi-fortran \
  --enable-mpi-interface-warning --enable-mpirun-prefix-by-default \
  --with-slurm \      
  --with-knem=${KNEM_ROOT} \
  --with-ucx=${PRFX}/ucx/${UCX_VERSION}-cuda-${CUDA_VERSION} \
  --with-pmi=${PRFX}/pmi2 --with-pmi-libdir=${PRFX}/pmi2/lib \
  --with-cuda=${NVHPC_ROOT}/cuda/${CUDA_VERSION} \
  --with-libevent=${PRFX}/libevent/${LIBEVENT_VERSION} \
  --prefix=${PRFX}/${OPENMPI_LABEL}/${OPENMPI_VERSION}-cuda-${CUDA_VERSION}-nvfortran

make -j 8
make -j 8 install
make -j 8 clean
```


Build and install OpenMPI for GPU (CUDA 12.4)
---------------------------------------------

```bash
cd ${OPENMPI_ROOT}/${OPENMPI_NAME}

module load zlib/1.3.1
module load gcc/10.2.0
module load nvidia/nvhpc-nompi/24.5

KNEM_ROOT=/opt/knem-1.1.4.90mlnx2

UCX_VERSION=1.16.0
CUDA_VERSION=12.4

./configure CC=gcc CXX=g++ FC=gfortran \
  CFLAGS="-I${PRFX}/pmi2/include" \
  LDFLAGS="-L${PRFX}/pmi2/lib" \
  --enable-mpi1-compatibility --enable-mpi-fortran \
  --enable-mpi-interface-warning --enable-mpirun-prefix-by-default \
  --with-slurm \
  --with-knem=${KNEM_ROOT} \
  --with-ucx=${PRFX}/ucx/${UCX_VERSION}-cuda-${CUDA_VERSION} \
  --with-pmi=${PRFX}/pmi2 --with-pmi-libdir=${PRFX}/pmi2/lib \
  --with-cuda=${NVHPC_ROOT}/cuda/${CUDA_VERSION} \
  --with-libevent=${PRFX}/libevent/${LIBEVENT_VERSION} \
  --prefix=${PRFX}/${OPENMPI_LABEL}/${OPENMPI_VERSION}-cuda-${CUDA_VERSION}

make -j 8
make -j 8 install
make -j 8 clean
```


Build and install OpenMPI for GPU (CUDA 12.4) with nvfortran
------------------------------------------------------------

```bash
cd ${OPENMPI_ROOT}/${OPENMPI_NAME}

module load zlib/1.3.1
module load gcc/10.2.0
module load nvidia/nvhpc-nompi/24.5

KNEM_ROOT=/opt/knem-1.1.4.90mlnx2

UCX_VERSION=1.16.0
CUDA_VERSION=12.4

./configure CC=gcc CXX=g++ FC=nvfortran \
  CFLAGS="-I${PRFX}/pmi2/include" \
  FCFLAGS="-fPIC" \
  LDFLAGS="-L${PRFX}/pmi2/lib -fPIC" \
  --enable-mpi1-compatibility --enable-mpi-fortran \
  --enable-mpi-interface-warning --enable-mpirun-prefix-by-default \
  --with-slurm \
  --with-knem=${KNEM_ROOT} \
  --with-ucx=${PRFX}/ucx/${UCX_VERSION}-cuda-${CUDA_VERSION} \
  --with-pmi=${PRFX}/pmi2 --with-pmi-libdir=${PRFX}/pmi2/lib \
  --with-cuda=${NVHPC_ROOT}/cuda/${CUDA_VERSION} \
  --with-libevent=${PRFX}/libevent/${LIBEVENT_VERSION} \
  --prefix=${PRFX}/${OPENMPI_LABEL}/${OPENMPI_VERSION}-cuda-${CUDA_VERSION}-nvfortran

make -j 8
make -j 8 install
make -j 8 clean
```
