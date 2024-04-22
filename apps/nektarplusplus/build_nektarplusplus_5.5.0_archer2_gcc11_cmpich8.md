Instructions for compiling Nektar++ 5.5.0 for ARCHER2
=====================================================

These instructions are for compiling Nektar++ 5.5.0 on the ARCHER2 (HPE Cray EX, AMD Zen2 7742) full system
using the GCC 11 compilers and Cray MPICH 8.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/apps/core
NEKTAR_VERSION=5.5.0
NEKTAR_LABEL=nektar
NEKTAR_ARCHIVE=${NEKTAR_LABEL}-v${NEKTAR_VERSION}.tar.gz
NEKTAR_NAME=${NEKTAR_LABEL}-${NEKTAR_VERSION}
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.


Download and unpack Nektar++
----------------------------

```bash
cd ${PRFX}
mkdir -p ${NEKTAR_LABEL}
cd ${NEKTAR_LABEL}

wget https://gitlab.nektar.info/nektar/nektar/-/archive/v${NEKTAR_VERSION}/${NEKTAR_ARCHIVE}
tar -xvzf ${NEKTAR_ARCHIVE}
rm ${NEKTAR_ARCHIVE}
mv ${NEKTAR_LABEL}-v${NEKTAR_VERSION} ${NEKTAR_NAME}
```


Switch to the GNU Programming Environment
-----------------------------------------

```bash
export CRAY_ADD_RPATH=yes

module -q load cpe/22.12
module -q load PrgEnv-gnu
module -q load cmake
```


Build and install Nektar++
--------------------------

```bash
cd ${NEKTAR_NAME}
mkdir build
cd build

INSTALL_ROOT=${PRFX}/${NEKTAR_LABEL}/${NEKTAR_VERSION}

CC=cc CXX=CC cmake -DNEKTAR_USE_MPI=ON -DNEKTAR_USE_HDF5=ON -DNEKTAR_USE_FFTW=ON \
    -DTHIRDPARTY_BUILD_BOOST=ON -DTHIRDPARTY_BUILD_HDF5=ON -DTHIRDPARTY_BUILD_FFTW=ON \
    -DNEKTAR_BUILD_UNIT_TESTS=OFF -DCMAKE_INSTALL_PREFIX=${INSTALL_ROOT} ..

make -j 8 install
make clean
```

The Nektar++ solver executables exist in the `${PRFX}/${NEKTAR_LABEL}/${NEKTAR_VERSION}/bin` directory.
