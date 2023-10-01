Instructions for building OpenMPI 4.1.5 on Cirrus
=================================================

These instructions are for building OpenMPI 4.1.5 on Cirrus (SGI ICE XA, Intel Xeon Broadwell (CPU) and Cascade Lake (GPU)) using gcc 8.2.0.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work # e.g., /mnt/lustre/indy2lfs/sw
OPENMPI_LABEL=openmpi
OPENMPI_VERSION=4.1.5
OPENMPI_VERSION_MAJOR=`echo ${OPENMPI_VERSION} | cut -d'.' -f1-2`
OPENMPI_NAME=${OPENMPI_LABEL}-${OPENMPI_VERSION}
OPENMPI_ROOT=${PRFX}/${OPENMPI_LABEL}

KNEM_ROOT=/opt/knem-1.1.4.90mlnx1

LIBEVENT_VERSION=2.1.12
UCX_VERSION=1.15.0

mkdir -p ${OPENMPI_ROOT}
cd ${OPENMPI_ROOT}

wget https://download.open-mpi.org/release/open-mpi/v${OPENMPI_VERSION_MAJOR}/${OPENMPI_NAME}.tar.gz
tar xzf ${OPENMPI_NAME}.tar.gz
rm ${OPENMPI_NAME}.tar.gz
cd ${OPENMPI_NAME}
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Build and install OpenMPI for CPU
---------------------------------

```bash
module load zlib/1.2.11
module load gcc/8.2.0

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
module load nvidia/nvhpc-nompi/22.2

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
