Instructions for compiling NAMD 3.0 for Cirrus (CPU)
====================================================

These instructions are for compiling NAMD 3.0 for Cirrus CPU (SGI ICE XA, Broadwell).


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/cirrus-software
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


Load the GCC, MPI and FFTW modules
----------------------------------

```bash
GNU_VERSION=10.2.0
GNU_VER=`echo ${GNU_VERSION} | cut -d'.' -f1-2`

IMPI_VERSION=20.4
FFTW_VERSION=3.3.10

module load gcc/${GNU_VERSION}
module load intel-${IMPI_VERSION}/mpi
module load fftw/${FFTW_VERSION}-gcc${GNU_VER}-impi${IMPI_VERSION}

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
make clean
```


Build and install various flavours of Charm++ suitable for CPU
--------------------------------------------------------------

```bash
cd ${NAMD_ROOT}/${NAMD_NAME}

NAMD_CHARM_NAME=charm-8.0.0
tar -xf ${NAMD_CHARM_NAME}.tar

cd ${NAMD_CHARM_NAME}

# MPI (with and without SMP), CPU
./build charm++ mpi-linux-x86_64 gcc smp --incdir=${I_MPI_ROOT}/intel64/include --libdir=${I_MPI_ROOT}/intel64/lib --libdir=${I_MPI_ROOT}/intel64/lib/release --libdir=${I_MPI_ROOT}/intel64/libfabric/lib --with-production
./build charm++ mpi-linux-x86_64 gcc --incdir=${I_MPI_ROOT}/intel64/include --libdir=${I_MPI_ROOT}/intel64/lib --libdir=${I_MPI_ROOT}/intel64/lib/release --libdir=${I_MPI_ROOT}/intel64/libfabric/lib --with-production
```


Build and install NAMD for each Charm++ flavour
-----------------------------------------------

```bash
FFTW_CPU_OPTIONS="--with-fftw3 --fftw-prefix ${PRFX}/fftw/${FFTW_VERSION}-gcc${GNU_VER}-impi${IMPI_VERSION}"

declare -a NAMD_VERSION_LABEL=("${NAMD_VERSION}" "${NAMD_VERSION}-nosmp")

declare -a CHARM_FLAVOUR=("mpi-linux-x86_64-smp-gcc" "mpi-linux-x86_64-gcc")
NUM_CHARM_FLAVOURS=${#CHARM_FLAVOUR[@]}

for (( i=0; i<${NUM_CHARM_FLAVOURS}; i++ )); do
  cd ${NAMD_ROOT}/${NAMD_NAME}

  ./config Linux-x86_64-g++ --charm-arch ${CHARM_FLAVOUR[$i]} \
      --with-tcl --tcl-prefix ${TCL_BASEDIR} ${FFTW_CPU_OPTIONS} \
      --cxx-opts "-L${I_MPI_ROOT}/intel64/libfabric/lib"

  cd ${NAMD_ROOT}/${NAMD_NAME}/Linux-x86_64-g++
  gmake

  NAMD_INSTALL_PATH=${NAMD_ROOT}/${NAMD_VERSION_LABEL[$i]}
  rm -rf ${NAMD_INSTALL_PATH}
  mkdir -p ${NAMD_INSTALL_PATH}
  cd ${NAMD_INSTALL_PATH}

  cp -r ${NAMD_ROOT}/${NAMD_NAME}/Linux-x86_64-g++ bin
  cd bin
  rm .rootdir
  ln -s ${NAMD_ROOT}/${NAMD_NAME} .rootdir

  rm -rf ${NAMD_ROOT}/${NAMD_NAME}/Linux-x86_64-g++
done
```

The `namd3` executables exist in the `${NAMD_ROOT}/${NAMD_VERSION_LABEL[$i]}/bin` directories.
