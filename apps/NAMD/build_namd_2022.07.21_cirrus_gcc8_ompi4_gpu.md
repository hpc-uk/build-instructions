Instructions for compiling NAMD Source Build 2022-07-21 for Cirrus (GPU)
========================================================================

These instructions are for compiling NAMD Source Build 2022-07-21 for Cirrus GPU (Cascade Lake, NVIDIA Tesla V100-SXM2-16GB).


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work # e.g., PRFX=/mnt/lustre/indy2lfs/sw
NAMD_LABEL=namd
NAMD_LABEL_CAPS=`echo ${NAMD_LABEL} | tr [a-z] [A-Z]`
NAMD_VERSION=2022.07.21
NAMD_ROOT=${PRFX}/${NAMD_LABEL}
NAMD_NAME=${NAMD_LABEL}-${NAMD_VERSION}
NAMD_ARCHIVE=${NAMD_LABEL_CAPS}_${NAMD_VERSION}_Source
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Download and unpack NAMD
------------------------

Next, download the NAMD 2022-07-21 source from: https://www.ks.uiuc.edu/Development/Download/download.cgi?UserID=&AccessCode=&ArchiveID=1640
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
GNU_VERSION=8.2.0
CUDA_VERSION=11.8
OMPI_VERSION=4.1.4
FFTW_VERSION=3.3.9

GNU_VERSION_MAJOR=`echo ${GNU_VERSION} | cut -d'.' -f1`
CUDA_VERSION_MAJOR=`echo ${CUDA_VERSION} | cut -d'.' -f1`
OMPI_VERSION_MAJOR=`echo ${OMPI_VERSION} | cut -d'.' -f1`

module load gcc/${GNU_VERSION}
module load openmpi/${OMPI_VERSION}-cuda-${CUDA_VERSION}
module load fftw/${FFTW_VERSION}-ompi${OMPI_VERSION_MAJOR}-cuda${CUDA_VERSION_MAJOR}-gcc${GNU_VERSION_MAJOR}

export FC=gfortran CC=gcc CXX=g++
```


Download, build and install TCL
-------------------------------

```bash
TCL_LABEL=tcl
TCL_VERSION=8.5.9
TCL_ROOT=${NAMD_ROOT}/${TCL_LABEL}
TCL_NAME=${TCL_LABEL}-${TCL_VERSION}
TCL_ARCHIVE=${TCL_LABEL}${TCL_VERSION}-src
TCL_BASEDIR=${TCL_ROOT}/${TCL_VERSION}

mkdir -p ${TCL_ROOT}
cd ${TCL_ROOT}

wget http://www.ks.uiuc.edu/Research/${NAMD_LABEL}/libraries/${TCL_ARCHIVE}.tar.gz
tar -xzf ${TCL_ARCHIVE}.tar.gz
rm ${TCL_ARCHIVE}.tar.gz
mv ${TCL_LABEL}${TCL_VERSION} ${TCL_NAME}

cd ${TCL_NAME}/unix

./configure --enable-threads --prefix=${TCL_ROOT}/${TCL_VERSION}
make
make test
make install
```


Build and install Charm++ suitable for GPU
------------------------------------------

```bash
cd ${NAMD_ROOT}/${NAMD_NAME}

CHARM_LABEL=charm
CHARM_VERSION=7.0.0
CHARM_NAME=${CHARM_LABEL}-${CHARM_VERSION}

PMI2_ROOT=/mnt/lustre/indy2lfs/sw/pmi2

wget http://charm.cs.illinois.edu/distrib/${CHARM_NAME}.tar.gz
tar -xf ${CHARM_NAME}.tar
mv ${CHARM_LABEL}-v${CHARM_VERSION} ${CHARM_NAME}
cd ${CHARM_NAME}

# ucx (with SMP), GPU
./build charm++ ucx-linux-x86_64 --incdir=${PMI2_ROOT}/include --libdir=${PMI2_ROOT}/lib slurmpmi2 \
    gcc smp --with-production --force



Build and install NAMD for GPU
------------------------------

```bash
NV_CUDA_VERSION=11.8
NV_SDK_VERSION_MAJOR=22
NV_SDK_VERSION_MINOR=11
NV_SDK_VERSION=${NV_SDK_VERSION_MAJOR}.${NV_SDK_VERSION_MINOR}
NV_SDK_NAME=hpcsdk-${NV_SDK_VERSION_MAJOR}${NV_SDK_VERSION_MINOR}
NV_SDK_ROOT=${PRFX}/nvidia/${NV_SDK_NAME}/Linux_x86_64/${NV_SDK_VERSION}

sed -i "s:CUDALIB=-L\$(CUDADIR)/lib64 -lcufft_static -lculibos -lcudart_static -lrt:CUDALIB=-L\$(CUDADIR)/lib64 -lcufft -lculibos -lcudart -lrt:g" ${NAMD_ROOT}/${NAMD_NAME}/arch/Linux-x86_64.cuda
sed -i "s:CHARMBASE = /Projects/namd2/charm-v7.0.0:CHARMBASE = /mnt/lustre/indy2lfs/sw/namd/namd-2022.07.21/charm-7.0.0:g" ${NAMD_ROOT}/${NAMD_NAME}/Make.charm

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

The `namd2` executable exists in the `${NAMD_ROOT}/${NAMD_VERSION}-gpu/bin` directory.
