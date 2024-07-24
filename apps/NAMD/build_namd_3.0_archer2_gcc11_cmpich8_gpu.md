Instructions for compiling NAMD Source Build 3.0 for ARCHER2 (GPU)
==================================================================

These instructions are for compiling NAMD Source Build 3.0 for ARCHER2 GPU (AMD MI210).


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work # e.g., PRFX=/work/y07/shared/apps/core
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


Switch to the GNU Programming Environment and load the appropriate modules
--------------------------------------------------------------------------

```bash
module -q load cpe/22.12
module -q load PrgEnv-gnu
module -q load rocm
module -q load craype-accel-amd-gfx90a
module -q load craype-x86-milan

module -q load cray-pmi
module -q load cray-fftw
module -q load cray-python
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

export FC=ftn CC=cc CXX=CC

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

wget http://charm.cs.illinois.edu/distrib/${CHARM_NAME}.tar.gz
tar -xzf ${CHARM_NAME}.tar.gz
mv ${CHARM_LABEL}-v${CHARM_VERSION} ${CHARM_NAME}
cd ${CHARM_NAME}

export FC=ftn CC=cc CXX=CC

./build charm++ mpi-crayshasta gcc smp --incdir=${MPICH_DIR}/include --libdir=${MPICH_DIR}/lib --with-production
```


Build and install NAMD for GPU
------------------------------

```bash
sed -i "s:CHARMBASE = /Projects/namd2/charm-8.0.0:CHARMBASE = /work/y07/shared/apps/core/namd/namd-3.0/charm-8.0.0:g" ${NAMD_ROOT}/${NAMD_NAME}/Make.charm

cd ${NAMD_ROOT}/${NAMD_NAME}

CHARM_FLAVOUR=mpi-crayshasta-smp-gcc

FFTW_OPTIONS="--with-fftw3 --fftw-prefix ${FFTW_ROOT}"
HIP_OPTIONS="--with-hip --rocm-prefix ${CRAY_ROCM_PREFIX}"

./config Linux-x86_64-g++ --charm-arch ${CHARM_FLAVOUR} \
    --with-tcl --tcl-prefix ${TCL_BASEDIR} \
    ${FFTW_OPTIONS} ${HIP_OPTIONS}

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
