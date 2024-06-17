Instructions for building OpenMPI 5.0.0 on CIRRUS
==================================================

These instructions are for building OpenMPI 5.0.0 on CIRRUS using gcc 10.2.0.

The instructions cover builds for both the CPU and GPU (CUDA 11.6 and 12.4) nodes.
In order to install OpenMPI you will need to install two additional libraries: `hwloc` and `pmix`.


Setup initial environment
-------------------------

First you need to setup the environment. 
The environment variables `HWLOC_ROOT`,`PMIX_ROOT`, `OPENMPI_ROOT` point to the directories where respectively `hwloc`, `pmix` and `openmpi` will be installed.
Below we specify them as subdirectories of `${BASE_PREFIX}`.
Remember to change the setting `BASE_PREFIX` to a path appropriate for your project.


```bash
module load gcc/10.2.0

export BASE_PREFIX=/work/y07/shared/cirrus-software # Base directory where to install openmpi and its dependencies. Change to your custom directory

# Define compilers
export CC=gcc 
export CXX=g++
export FC=gfortran

CC_VERSION=$($CC --version | head -n 1 |  awk '{ print $3}') # get the version from the executable. This is used to define the path of all libraries required by the install

LIBEVENT_ROOT=${BASE_PREFIX}/libevent/2.1.12

HWLOC_VERSION=2.9.3
HWLOC_ROOT=${BASE_PREFIX}/hwloc/hwloc-${HWLOC_VERSION}-${CC}-${CC_VERSION}

PMIX_VERSION=4.2.7
PMIX_ROOT=${BASE_PREFIX}/pmix/pmix-${PMIX_VERSION}-${CC}-${CC_VERSION}

OPENMPI_VERSION=5.0.0
OPENMPI_ROOT=${BASE_PREFIX}/openmpi
mkdir -p ${OPENMPI_ROOT}
```


Install hwloc
-------------------------

```bash 
mkdir -p ${HWLOC_ROOT}
cd ${HWLOC_ROOT}
cd ../

HWLOC=hwloc-${HWLOC_VERSION}
wget https://download.open-mpi.org/release/hwloc/v2.9/${HWLOC}.tar.gz .

tar xvf ${HWLOC}.tar.gz
rm ${HWLOC}.tar.gz

cd ${HWLOC}

module load gcc/10.2.0

./configure --prefix=${HWLOC_ROOT}

make -j 8 
make -j 8 install
make -j 8 clean
```


Install pmix
-------------------------

```bash
mkdir -p ${PMIX_ROOT}
cd ${PMIX_ROOT}
cd ../

PMIX=pmix-$PMIX_VERSION
wget https://github.com/openpmix/openpmix/releases/download/v${PMIX_VERSION}/${PMIX}.tar.gz

tar -xvf ${PMIX}.tar.gz 
rm ${PMIX}.tar.gz

cd ${PMIX}
mkdir build
cd build

module load gcc/10.2.0

../configure CFLAGS="-I${HWLOC_ROOT}/include" LDFLAGS="-L${HWLOC_ROOT}/lib" --with-hwloc=${HWLOC_ROOT} --with-libevent=${LIBEVENT_ROOT} --prefix=${PMIX_ROOT}

make -j 8
make -j 8 install
make -j 8 clean
```


Download OpenMPI source code
----------------------------

```
mkdir -p ${OPENMPI_ROOT}
cd ${OPENMPI_ROOT}
OMPI="openmpi-${OPENMPI_VERSION}"

wget https://download.open-mpi.org/release/open-mpi/v`echo ${OPENMPI_VERSION} | cut -c1-3`/${OMPI}.tar.gz
tar -xvf ${OMPI}.tar.gz
rm ${OMPI}.tar.gz
```


Install OpenMPI for CPU
-----------------------

```bash 
cd ${OPENMPI_ROOT}/${OMPI}

KNEM_ROOT=/opt/knem-1.1.4.90mlnx1

UCX_VERSION=1.15.0

CFLAGS="-I${HWLOC_ROOT}/include -I${PMIX_ROOT}/include"
LDFLAGS="-L${PMIX_ROOT}/lib -L${HWLOC_ROOT}/lib"

CONF="CC=${CC} CXX=${CXX} FC=${FC} "\
"--enable-mpi1-compatibility "\
"--enable-mpi-fortran "\
"--enable-mpi-interface-warning "\
"--enable-mpirun-prefix-by-default --with-slurm "\
"--with-knem=${KNEM_ROOT} "\
"--with-ucx=${BASE_PREFIX}/ucx/${UCX_VERSION} "\
"--with-pmix=${PMIX_ROOT} "\
"--with-pmix-libdir=${PMIX_ROOT}/lib "\
"--with-libevent=${LIBEVENT_ROOT} "\
"--with-hwloc=${HWLOC_ROOT} "\
"--without-cuda --without-hcoll"

mkdir -p build
cd build

module load gcc/10.2.0

../configure CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" $CONF --prefix=${OPENMPI_ROOT}/${OPENMPI_VERSION}

make -j 8 2>&1 | tee make-cpu.log

make -j 8 install
make -j 8 clean
```


Install OpenMPI for GPU (CUDA 11.6)
-----------------------------------

```bash
cd ${OPENMPI_ROOT}/${OMPI}

module load gcc/10.2.0
module load nvidia/nvhpc-nompi/22.2

KNEM_ROOT=/opt/knem-1.1.4.90mlnx1

UCX_VERSION=1.15.0
CUDA_VERSION=11.6

CFLAGS="-I${HWLOC_ROOT}/include -I${PMIX_ROOT}/include"
LDFLAGS="-L${PMIX_ROOT}/lib -L${HWLOC_ROOT}/lib"


CONF="CC=gcc CXX=g++ FC=gfortran "\
"--enable-mpi1-compatibility "\
"--enable-mpi-fortran "\
"--enable-mpi-interface-warning "\
"--enable-mpirun-prefix-by-default --with-slurm "\
"--with-knem=${KNEM_ROOT} "\
"--with-ucx=${BASE_PREFIX}/ucx/${UCX_VERSION}-cuda-${CUDA_VERSION} "\
"--with-pmix=${PMIX_ROOT} "\
"--with-pmix-libdir=${PMIX_ROOT}/lib "\
"--with-libevent=${LIBEVENT_ROOT} "\
"--with-hwloc=${HWLOC_ROOT} "\
"--with-cuda=${NVHPC_ROOT}/cuda/${CUDA_VERSION} "\
"--without-hcoll"

mkdir -p build
cd build

../configure CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" $CONF --prefix=${OPENMPI_ROOT}/${OPENMPI_VERSION}-cuda-${CUDA_VERSION}

make -j 8 2>&1 | tee make-gpu.log

make -j 8 install
make -j 8 clean
```


Install OpenMPI for GPU (CUDA 12.4)
-----------------------------------

```bash
cd ${OPENMPI_ROOT}/${OMPI}

module load gcc/10.2.0
module load nvidia/nvhpc-nompi/24.5

KNEM_ROOT=/opt/knem-1.1.4.90mlnx2

UCX_VERSION=1.16.0
CUDA_VERSION=12.4

CFLAGS="-I${HWLOC_ROOT}/include -I${PMIX_ROOT}/include"
LDFLAGS="-L${PMIX_ROOT}/lib -L${HWLOC_ROOT}/lib"


CONF="CC=gcc CXX=g++ FC=gfortran "\
"--enable-mpi1-compatibility "\
"--enable-mpi-fortran "\
"--enable-mpi-interface-warning "\
"--enable-mpirun-prefix-by-default --with-slurm "\
"--with-knem=${KNEM_ROOT} "\
"--with-ucx=${BASE_PREFIX}/ucx/${UCX_VERSION}-cuda-${CUDA_VERSION} "\
"--with-pmix=${PMIX_ROOT} "\
"--with-pmix-libdir=${PMIX_ROOT}/lib "\
"--with-libevent=${LIBEVENT_ROOT} "\
"--with-hwloc=${HWLOC_ROOT} "\
"--with-cuda=${NVHPC_ROOT}/cuda/${CUDA_VERSION} "\
"--without-hcoll"

mkdir -p build
cd build

../configure CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" $CONF --prefix=${OPENMPI_ROOT}/${OPENMPI_VERSION}-cuda-${CUDA_VERSION}

make -j 8 2>&1 | tee make-gpu.log

make -j 8 install
make -j 8 clean
```
