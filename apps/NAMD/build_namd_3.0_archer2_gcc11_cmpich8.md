Instructions for compiling NAMD 3.0 for ARCHER2 (CPU)
=====================================================

These instructions are for compiling NAMD 3.0 (with and without SMP) on ARCHER2 (HPE Cray EX, AMD Zen2 7742) using the GCC 11 compilers and Cray MPICH 8.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/apps/core
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

Next, download the NAMD 3.0 source from: http://www.ks.uiuc.edu/Development/Download/download.cgi?PackageName=NAMD
and transfer to the Cirrus system at the path indicated by `$NAMD_ROOT/arc`.

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
module -q load cray-pmi
module -q load cray-fftw
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
export FC=ftn CC=cc CXX=CC

./configure --enable-threads --prefix=${TCL_ROOT}/${TCL_VERSION}
make
make test
make install
make clean
```


Build and install various flavours of Charm++ suitable for CPU
--------------------------------------------------------------

```bash
cd ${NAMD_ROOT}/${NAMD_NAME}

NAMD_CHARM_NAME=charm-8.0.0
tar -xf ${NAMD_CHARM_NAME}.tar

cd ${NAMD_CHARM_NAME}

export FC=ftn CC=cc CXX=CC

./build charm++ mpi-crayshasta gcc smp --incdir=${MPICH_DIR}/include --libdir=${MPICH_DIR}/lib --with-production
./build charm++ mpi-crayshasta gcc --incdir=${MPICH_DIR}/include --libdir=${MPICH_DIR}/lib --with-production
```


Build and install NAMD (SMP version)
------------------------------------

```bash
cd ${NAMD_ROOT}/${NAMD_NAME}
./config Linux-x86_64-g++ --tcl-prefix ${TCL_BASEDIR} --with-fftw3 --fftw-prefix ${FFTW_ROOT} --charm-arch mpi-crayshasta-smp-gcc
cd ${NAMD_ROOT}/${NAMD_NAME}/Linux-x86_64-g++
gmake

mkdir -p ${NAMD_ROOT}/${NAMD_VERSION}
cd ${NAMD_ROOT}/${NAMD_VERSION}
cp -r ${NAMD_ROOT}/${NAMD_NAME}/Linux-x86_64-g++ bin
cd bin
rm .rootdir
ln -s ${NAMD_ROOT}/${NAMD_NAME} .rootdir

rm -rf ${NAMD_ROOT}/${NAMD_NAME}/Linux-x86_64-g++
```

The `namd3` executable exists in the `${NAMD_ROOT}/${NAMD_VERSION}/bin` directory.


Build and install NAMD (non-SMP version)
----------------------------------------

```bash
cd ${NAMD_ROOT}/${NAMD_NAME}
./config Linux-x86_64-g++ --tcl-prefix ${TCL_BASEDIR} --with-fftw3 --fftw-prefix ${FFTW_ROOT} --charm-arch mpi-crayshasta-gcc
cd ${NAMD_ROOT}/${NAMD_NAME}/Linux-x86_64-g++
gmake

mkdir -p ${NAMD_ROOT}/${NAMD_VERSION}-nosmp
cd ${NAMD_ROOT}/${NAMD_VERSION}-nosmp
cp -r ${NAMD_ROOT}/${NAMD_NAME}/Linux-x86_64-g++ bin
cd bin
rm .rootdir
ln -s ${NAMD_ROOT}/${NAMD_NAME} .rootdir

rm -rf ${NAMD_ROOT}/${NAMD_NAME}/Linux-x86_64-g++
```

This `namd3` executable exists in the `${NAMD_ROOT}/${NAMD_VERSION}-nosmp/bin` directory.
