Instructions for building OpenMPI 4.1.4 on Cirrus
=================================================

These instructions are for building OpenMPI 4.1.4 on Cirrus (SGI ICE XA, Intel Xeon Broadwell (CPU) and Cascade Lake (GPU)) using gcc 8.2.0.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work # e.g., /mnt/lustre/indy2lfs/sw
OPENMPI_LABEL=openmpi
OPENMPI_VERSION=4.1.4
OPENMPI_VERSION_MAJOR=`echo ${OPENMPI_VERSION} | cut -d'.' -f1-2`
OPENMPI_NAME=${OPENMPI_LABEL}-${OPENMPI_VERSION}

mkdir -p ${PRFX}/${OPENMPI_LABEL}
cd ${PRFX}/${OPENMPI_LABEL}

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
  --with-ucx=${PRFX}/ucx/1.9.0 \
  --with-pmi=${PRFX}/pmi2 --with-pmi-libdir=${PRFX}/pmi2/lib \
  --with-libevent=${PRFX}/libevent/2.1.12 \
  --prefix=${PRFX}/${OPENMPI_LABEL}/${OPENMPI_VERSION}

make
make install
make clean
```


Build and install OpenMPI for GPU (CUDA 11.6)
---------------------------------------------

```bash
module load nvidia/nvhpc-nompi/22.2

./configure CC=gcc CXX=g++ FC=gfortran \
  CFLAGS="-I${PRFX}/pmi2/include" \
  LDFLAGS="-L${PRFX}/pmi2/lib" \
  --enable-mpi1-compatibility --enable-mpi-fortran \
  --enable-mpi-interface-warning --enable-mpirun-prefix-by-default \
  --with-slurm \
  --with-ucx=${PRFX}/ucx/1.9.0-cuda-11.6 \
  --with-pmi=${PRFX}/pmi2 --with-pmi-libdir=${PRFX}/pmi2/lib \
  --with-cuda=${NVHPC_ROOT}/cuda/11.6 \
  --with-libevent=${PRFX}/libevent/2.1.12 \
  --prefix=${PRFX}/${OPENMPI_LABEL}/${OPENMPI_VERSION}-cuda-11.6

make
make install
make clean
```