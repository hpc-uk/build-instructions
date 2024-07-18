Instructions for compiling NAMD Source Build 3.0 for Cirrus (GPU)
=================================================================

These instructions are for compiling NAMD Source Build 3.0 for Cirrus GPU (Cascade Lake, NVIDIA Tesla V100-SXM2-16GB).


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work # e.g., PRFX=/work/y07/shared/cirrus-software
NAMD_LABEL=namd
NAMD_LABEL_CAPS=`echo ${NAMD_LABEL} | tr [a-z] [A-Z]`
NAMD_VERSION=3.0
NAMD_ROOT=${PRFX}/${NAMD_LABEL}
NAMD_NAME=${NAMD_LABEL}-${NAMD_VERSION}
NAMD_ARCHIVE=${NAMD_LABEL_CAPS}_${NAMD_VERSION}_Source
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Download and unpack NAMD
------------------------

Next, download the NAMD 3.0 source from: https://www.ks.uiuc.edu/Development/Download/download.cgi?UserID=&AccessCode=&ArchiveID=1640
and transfer to the Cirrus system at the path indicated by `${NAMD_ROOT}/arc`.

Unpack the source.

```bash
cd ${NAMD_ROOT} 
cp ${NAMD_ROOT}/arc/${NAMD_ARCHIVE}.tar.gz ${NAMD_ROOT}/
tar -xzf ${NAMD_ARCHIVE}.tar.gz
rm ${NAMD_ARCHIVE}.tar.gz
mv ${NAMD_ARCHIVE} ${NAMD_NAME}
```


Load the GCC, MPI and FFTW modules
----------------------------------

```bash
GNU_VERSION=10.2.0
CUDA_VERSION=12.4
OMPI_VERSION=4.1.6
FFTW_VERSION=3.3.10

GNU_VER=`echo ${GNU_VERSION} | cut -d'.' -f1-2`
OMPI_VERSION_MAJOR=`echo ${OMPI_VERSION} | cut -d'.' -f1`

module load gcc/${GNU_VERSION}
module load nvidia/nvhpc-nompi/24.5
module load openmpi/${OMPI_VERSION}-cuda-${CUDA_VERSION}
module load fftw/${FFTW_VERSION}-gcc${GNU_VER}-ompi${OMPI_VERSION_MAJOR}-cuda${CUDA_VERSION}

export FC=gfortran CC=gcc CXX=g++
```


Setup TCL environment
---------------------

```bash
TCL_LABEL=tcl
TCL_VERSION=8.6.13
TCL_ROOT=${NAMD_ROOT}/${TCL_LABEL}
TCL_NAME=${TCL_LABEL}-${TCL_VERSION}
TCL_ARCHIVE=${TCL_LABEL}${TCL_VERSION}-src
TCL_BASEDIR=${TCL_ROOT}/${TCL_VERSION}

mkdir -p ${TCL_ROOT}/arc
```


Download and unpack TCL
------------------------

Next, download the TCL 8.6.13 source from: https://sourceforge.net/projects/tcl/files/Tcl/8.6.13/tcl8.6.13-src.tar.gz/download
and transfer to the Cirrus system at the path indicated by `${TCL_ROOT}/arc`.

Unpack the source.

```bash
cd ${TCL_ROOT}
cp ${TCL_ROOT}/arc/${TCL_ARCHIVE}.tar.gz ${TCL_ROOT}/
tar -xzf ${TCL_ARCHIVE}.tar.gz
rm ${TCL_ARCHIVE}.tar.gz
mv ${TCL_LABEL}${TCL_VERSION} ${TCL_NAME}
```


Build and install TCL
---------------------

```bash
cd ${TCL_ROOT}/${TCL_NAME}/unix

./configure --enable-threads --prefix=${TCL_ROOT}/${TCL_VERSION}
make
make test
make install
make clean
```


Build and install Charm++ suitable for GPU
------------------------------------------

```bash
cd ${NAMD_ROOT}/${NAMD_NAME}

CHARM_LABEL=charm
CHARM_VERSION=8.0.0
CHARM_NAME=${CHARM_LABEL}-${CHARM_VERSION}

PMI2_ROOT=/work/y07/shared/cirrus-software/pmi2

wget http://charm.cs.illinois.edu/distrib/${CHARM_NAME}.tar.gz
tar -xzf ${CHARM_NAME}.tar.gz
mv ${CHARM_LABEL}-v${CHARM_VERSION} ${CHARM_NAME}
cd ${CHARM_NAME}

# ucx (with SMP), GPU
./build charm++ ucx-linux-x86_64 --incdir=${PMI2_ROOT}/include --libdir=${PMI2_ROOT}/lib slurmpmi2 \
    gcc smp --with-production --force
```


Build and install NAMD for GPU
------------------------------

```bash
NV_CUDA_VERSION=12.4
NV_SDK_VERSION_MAJOR=24
NV_SDK_VERSION_MINOR=5
NV_SDK_VERSION=${NV_SDK_VERSION_MAJOR}.${NV_SDK_VERSION_MINOR}
NV_SDK_NAME=hpcsdk-${NV_SDK_VERSION_MAJOR}.${NV_SDK_VERSION_MINOR}
NV_SDK_ROOT=${PRFX}/nvidia/${NV_SDK_NAME}/Linux_x86_64/${NV_SDK_VERSION}

export NVHPCSDK_DIR=${NV_SDK_ROOT}

sed -i "s:CHARMBASE = /Projects/namd2/charm-8.0.0:CHARMBASE = /work/y07/shared/cirrus-software/namd/namd-3.0/charm-8.0.0:g" ${NAMD_ROOT}/${NAMD_NAME}/Make.charm

cd ${NAMD_ROOT}/${NAMD_NAME}

CHARM_FLAVOUR=ucx-linux-x86_64-slurmpmi2-smp-gcc

FFTW_OPTIONS="--with-fftw3 --fftw-prefix ${NV_SDK_ROOT}/math_libs/${NV_CUDA_VERSION}/targets/x86_64-linux"
CUDA_OPTIONS="--with-cuda --cuda-prefix ${NV_SDK_ROOT}/cuda/${NV_CUDA_VERSION}"

./config Linux-x86_64-g++ --charm-arch ${CHARM_FLAVOUR} \
    --with-tcl --tcl-prefix ${TCL_BASEDIR} \
    ${FFTW_OPTIONS} ${CUDA_OPTIONS}

cd ${NAMD_ROOT}/${NAMD_NAME}/Linux-x86_64-g++
gmake

NAMD_INSTALL_PATH=${NAMD_ROOT}/${NAMD_VERSION}-gpu
rm -rf ${NAMD_INSTALL_PATH}
mkdir -p ${NAMD_INSTALL_PATH}
cd ${NAMD_INSTALL_PATH}

cp -r ${NAMD_ROOT}/${NAMD_NAME}/Linux-x86_64-g++ bin
cd bin
rm .rootdir
ln -s ${NAMD_ROOT}/${NAMD_NAME} .rootdir

rm -rf ${NAMD_ROOT}/${NAMD_NAME}/Linux-x86_64-g++
```

The `namd3` executable exists in the `${NAMD_ROOT}/${NAMD_VERSION}-gpu/bin` directory.
