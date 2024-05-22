Instructions for compiling GROMACS 2024.2 for ARCHER2 using CPE 15 compilers
============================================================================

These instructions are for compiling GROMACS 2024.2 on [ARCHER2](https://www.archer2.ac.uk) using the CPE 15 compilers.

Download and Unpack the GROMACS source code
-------------------------------------------

Download and unpack the source

```bash
wget http://ftp.gromacs.org/pub/gromacs/gromacs-2024.2.tar.gz
tar -xvf gromacs-2024.2.tar.gz
cd gromacs-2024.2
export SRC=$(pwd)
```

Setup correct modules and build environment
-------------------------------------------

Setup the programming environment:

```bash
module load cpe/22.12
module load cray-python/3.9.13.1
module load cray-fftw/3.3.10.3
module load cmake/3.21.3
export LD_LIBRARY_PATH=$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH
```

These options are needed to be set correctly for any of the following steps.

Configure and build the parallel, single-precision build
--------------------------------------------------------

Create a build directory in the source tree

```bash
cd ${SRC}
mkdir build_mpi
cd build_mpi
```

Use CMake to configure the build and then build and install. Remember to set the install 
prefix to somewhere you have permission to write to.

```bash
export CC=cc
export CXX=CC
export GMX_INSTALL=/work/y07/shared/apps/core/gromacs/2024.2

cmake                                       \
      -DGMX_MPI=ON                          \
      -DGMX_OPENMP=ON                       \
      -DGMX_GPU=OFF                         \
      -DGMX_DOUBLE=OFF                      \
      -DGMX_BUILD_OWN_FFTW=OFF              \
      -DCMAKE_INSTALL_PREFIX=${GMX_INSTALL} \
      ../

make -j 8
make install
```

Configure and build the parallel, double-precision build
--------------------------------------------------------

Create a build directory in the source tree

```bash
cd ${SRC}
mkdir build_double
cd build_double
```

Use CMake to configure the build and then build and install. Remember to set the install 
prefix to somewhere you have permission to write to.

```bash
export CC=cc
export CXX=CC
export GMX_INSTALL=/work/y07/shared/apps/core/gromacs/2024.2

cmake                                       \
      -DGMX_MPI=ON                          \
      -DGMX_OPENMP=ON                       \
      -DGMX_GPU=OFF                         \
      -DGMX_DOUBLE=ON                       \
      -DGMX_BUILD_OWN_FFTW=OFF              \
      -DCMAKE_INSTALL_PREFIX=${GMX_INSTALL} \
      ../

make -j 8
make install
```

Configure and build the serial, single-precision build
-------------------------------------------------------

The serial build is required for the GROMACS analysis utilities.

Create a build directory in the source tree

```bash
cd ${SRC}
mkdir build_serial
cd build_serial
```

Use CMake to configure the build and then build and install. Remember to set the install 
prefix to somewhere you have permission to write to.

```bash
export CC=cc
export CXX=CC
export GMX_INSTALL=/work/y07/shared/apps/core/gromacs/2024.2

cmake                                       \
      -DGMX_MPI=OFF                         \
      -DGMX_OPENMP=ON                       \
      -DGMX_GPU=OFF                         \
      -DGMX_DOUBLE=OFF                      \
      -DGMX_BUILD_OWN_FFTW=OFF              \
      -DCMAKE_INSTALL_PREFIX=${GMX_INSTALL} \
      ../

make -j 8
make install
```



NOT IMPLEMENTED:
================
GROMACS + PLUMED
================
PLUMED NOT YET COMPATIBLE
=========================

Compiling GROMACS with plumed support. Assumes that no module is loaded.

Download and Unpack the PLUMED source code
------------------------------------------

Download and unpack the source

```bash
wget https://github.com/plumed/plumed2/archive/refs/tags/v2.9.0.tar.gz
tar -xvf v2.9.0.tar.gz
cd plumed2-2.9.0
export PLMD_SRC=$(pwd)
```

Setup correct modules and build environment
-------------------------------------------

Setup the programming environment:

```bash
module load cpe/22.12
module load cray-fftw/3.3.10.3
module load cmake/3.21.3
export LD_LIBRARY_PATH=$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH
```

Set compilers to ARCHER2 compiler wrappers

```bash
export CC=cc
export CXX=CC
export FC=ftn
export MPIEXEC=srun
```

Set install paths. Structure is: `BASE_DIR` contains `GROMACS_DIR` and `PLUMED_DIR`.


```bash
export BASE_DIR=/work/y07/shared/apps/core/gromacs/2024.2+plumed2.9.0
export GROMACS_DIR=${BASE_DIR}/gromacs-2024.2/
export PLUMED_DIR=${BASE_DIR}/plumed2-2.9.0/
```

Configure and compile PLUMED
----------------------------

Run the configuration file with the options below, and compile PLUMED.

```bash
./configure --enable-shared --prefix=${PLUMED_DIR}
make -j 8
make install
export PATH=$PATH:${PLUMED_DIR}/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${PLUMED_DIR}/lib
```

It is possible to run regression tests on the compiled binary with `make check` or the installed binary with `make installcheck`.

Regression tests can also be run, using the plumed in the path:

```bash
cd regtest
make
```

Patch and build GROMACS
-----------------------

Download and unpack GROMACS:

```bash
wget http://ftp.gromacs.org/pub/gromacs/gromacs-2024.2.tar.gz
mkdir gromacs-2024.2+plumed2.9.0
tar -xvf gromacs-2024.2.tar.gz -C gromacs-2024.2+plumed2.9.0 --strip-components 1
cd gromacs-2024.2+plumed2.9.0
export SRC=$(pwd)
```

In the root folder for GROMACS:

```bash
plumed patch -p
```

and select the corresponding GROMACS version.


Configure and build the parallel, single-precision build
--------------------------------------------------------

Create a build directory in the source tree

```bash
cd ${SRC}
mkdir build_plumed_mpi
cd build_plumed_mpi
```

Use CMake to configure the build and then build and install. Remember to set the install 
prefix to somewhere you have permission to write to.

```bash
cmake -D GMX_MPI=ON                       \
      -D GMX_OPENMP=ON                    \
      -D GMX_GPU=OFF                      \
      -D GMX_DOUBLE=OFF                   \
      -D GMX_BUILD_OWN_FFTW=OFF           \
      -D CMAKE_INSTALL_PREFIX=${BASE_DIR} \
      ../
make -j 8
make install
```

Configure and build the parallel, double-precision build
--------------------------------------------------------

Create a build directory in the source tree

```bash
cd ${SRC}
mkdir build_plumed_double
cd build_plumed_double
```

Use CMake to configure the build and then build and install. Remember to set the install 
prefix to somewhere you have permission to write to.

```bash
cmake -D GMX_MPI=ON                       \
      -D GMX_OPENMP=ON                    \
      -D GMX_GPU=OFF                      \
      -D GMX_DOUBLE=ON                    \
      -D GMX_BUILD_OWN_FFTW=OFF           \
      -D CMAKE_INSTALL_PREFIX=${BASE_DIR} \
      ../
make -j 8
make install
```

Configure and build the serial, single-precision build
-------------------------------------------------------

The serial build is required for the GROMACS analysis utilities.

Create a build directory in the source tree

```bash
cd ${SRC}
mkdir build_plumed_serial
cd build_plumed_serial
```

Use CMake to configure the build and then build and install. Remember to set the install 
prefix to somewhere you have permission to write to.

```bash
cmake -D GMX_MPI=OFF                      \
      -D GMX_OPENMP=ON                    \
      -D GMX_GPU=OFF                      \
      -D GMX_DOUBLE=OFF                   \
      -D GMX_BUILD_OWN_FFTW=OFF           \
      -D CMAKE_INSTALL_PREFIX=${BASE_DIR} \
make -j 8
make install
```
