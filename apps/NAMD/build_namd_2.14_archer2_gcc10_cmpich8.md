Instructions for compiling NAMD 2.14 for ARCHER2
================================================

These instructions are for compiling NAMD 2.14 (with and without SMP) on ARCHER2 (HPE Cray EX, AMD Zen2 7742) using the GCC 10 compilers and Cray MPICH 8.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work
NAMD_LABEL=namd
NAMD_LABEL_CAPS=`echo ${NAMD_LABEL} | tr [a-z] [A-Z]`
NAMD_VERSION=2.14
NAMD_ROOT=${PRFX}/${NAMD_LABEL}
NAMD_NAME=${NAMD_LABEL}-${NAMD_VERSION}
NAMD_ARCHIVE=${NAMD_LABEL_CAPS}_${NAMD_VERSION}_Source
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.


Download and unpack NAMD
------------------------

Next, download the NAMD source from: http://www.ks.uiuc.edu/Development/Download/download.cgi?PackageName=NAMD
and transfer to the ARCHER2 system at the path indicated by `$NAMD_ROOT/arc`.

Unpack the source.

```bash
cd ${NAMD_ROOT} 
cp ${NAMD_ROOT}/arc/${NAMD_ARCHIVE}.tar.gz ${NAMD_ROOT}/
tar -xzf ${NAMD_ARCHIVE}.tar.gz
rm ${NAMD_ARCHIVE}.tar.gz
mv ${NAMD_ARCHIVE} ${NAMD_NAME}
```


Switch to the GNU Programming Environment and load the approptiate FFTW module
------------------------------------------------------------------------------

```bash
module restore /etc/cray-pe.d/PrgEnv-gnu

GNU_VERSION_MAJOR=`echo ${GNU_VERSION} | cut -d'.' -f1`
FFTW_VERSION=3.3.8.7

module load cray-fftw/${FFTW_VERSION}
```


Download, build and install TCL
-------------------------------

```bash
TCL_LABEL=tcl
TCL_VERSION=8.5.9
TCL_ROOT=${NAMD_ROOT}/${TCL_LABEL}
TCL_NAME=${TCL_LABEL}-${TCL_VERSION}
TCL_ARCHIVE=${TCL_LABEL}${TCL_VERSION}-src

mkdir -p ${TCL_ROOT}
cd ${TCL_ROOT}

wget http://www.ks.uiuc.edu/Research/${NAMD_LABEL}/libraries/${TCL_ARCHIVE}.tar.gz
tar -xzf ${TCL_ARCHIVE}.tar.gz
rm ${TCL_ARCHIVE}.tar.gz
mv ${TCL_ARCHIVE} ${TCL_NAME}

cd ${TCL_NAME}/unix
export FC=ftn CC=cc CXX=CC

./configure --enable-threads --prefix=${TCL_ROOT}/${TCL_VERSION}-gcc${GNU_VERSION_MAJOR}
make
make test
make install
```


Build and install Charm++ (with and without SMP)
------------------------------------------------

```bash
cd ${NAMD_ROOT}/${NAMD_NAME}

NAMD_CHARM_NAME=charm-6.10.2
tar -xf ${NAMD_CHARM_NAME}.tar

TCL_BASEDIR=${TCL_ROOT}/${TCL_VERSION}-gcc${GNU_VERSION_MAJOR}

cd ${NAMD_CHARM_NAME}
export CRAY_MPICH_GNU_BASEDIR=${CRAY_MPICH_BASEDIR}/gnu/${PE_MPICH_GENCOMPILERS_GNU}

./build charm++ mpi-linux-amd64 gcc smp --incdir=${CRAY_MPICH_GNU_BASEDIR}/include --libdir=${CRAY_MPICH_GNU_BASEDIR}/lib --with-production
./build charm++ mpi-linux-amd64 gcc --incdir=${CRAY_MPICH_GNU_BASEDIR}/include --libdir=${CRAY_MPICH_GNU_BASEDIR}/lib --with-production
```


Build and install NAMD (SMP version)
------------------------------------

```bash
cd ${NAMD_ROOT}/${NAMD_NAME}
./config Linux-x86_64-g++ --tcl-prefix ${TCL_BASEDIR} --with-fftw3 --fftw-prefix ${FFTW_ROOT} --charm-arch mpi-linux-amd64-smp-gcc
cd ${NAMD_ROOT}/${NAMD_NAME}/Linux-x86_64-g++
gmake

mkdir -p ${NAMD_ROOT}/${NAMD_VERSION}-smp-gcc${GNU_VERSION_MAJOR}
cd ${NAMD_ROOT}/${NAMD_VERSION}-smp-gcc${GNU_VERSION_MAJOR}
cp -r ${NAMD_ROOT}/${NAMD_NAME}/Linux-x86_64-g++ bin
cd bin
rm .rootdir
ln -s ${NAMD_ROOT}/${NAMD_NAME} .rootdir

rm -rf ${NAMD_ROOT}/${NAMD_NAME}/Linux-x86_64-g++
```

The `namd2` executable exists in the `${NAMD_ROOT}/${NAMD_VERSION}-smp-gcc${GNU_VERSION_MAJOR}/bin` directory.


Build and install NAMD (non-SMP version)
----------------------------------------

```bash
cd ${NAMD_ROOT}/${NAMD_NAME}
./config Linux-x86_64-g++ --tcl-prefix ${TCL_BASEDIR} --with-fftw3 --fftw-prefix ${FFTW_ROOT} --charm-arch mpi-linux-amd64-gcc
cd ${NAMD_ROOT}/${NAMD_NAME}/Linux-x86_64-g++
gmake

mkdir -p ${NAMD_ROOT}/${NAMD_VERSION}-nosmp-gcc${GNU_VERSION_MAJOR}
cd ${NAMD_ROOT}/${NAMD_VERSION}-nosmp-gcc${GNU_VERSION_MAJOR}
cp -r ${NAMD_ROOT}/${NAMD_NAME}/Linux-x86_64-g++ bin
cd bin
rm .rootdir
ln -s ${NAMD_ROOT}/${NAMD_NAME} .rootdir

rm -rf ${NAMD_ROOT}/${NAMD_NAME}/Linux-x86_64-g++
```

This `namd2` executable exists in the `${NAMD_ROOT}/${NAMD_VERSION}-nosmp-gcc${GNU_VERSION_MAJOR}/bin` directory.