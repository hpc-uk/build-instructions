Instructions for compiling GROMACS 2020.2 for ARCHER2 using GCC 9 compilers
==========================================================================

These instructions are for compiling GROMACS 2020.2 on [ARCHER2](https://www.archer2.ac.uk) using the GCC 9 compilers.


Download and Unpack the GROMACS source code
-------------------------------------------

Download and unpack the source

```bash
wget http://ftp.gromacs.org/pub/gromacs/gromacs-2020.2.tar.gz
tar -xvf gromacs-2020.2.tar.gz
```

Setup correct modules
---------------------

Load the compiler and MPI modules

```bash
module swap PrgEnv-cray PrgEnv-gcc
```

Configure and build the parallel, single-precision build
--------------------------------------------------------

Create a build directory in the source tree

```bash
cd gromacs-2020.2
mkdir build_mpi
cd build_mpi
```

Use CMake to configure the build and then build and install. Remember to set the install 
prefix to somewhere you have permission to write to.

```bash
cmake ../ -DGMX_MPI=ON -DGMX_OPENMP=ON -DGMX_GPU=OFF -DGMX_X11=OFF -DGMX_DOUBLE=OFF \
          -DGMX_BUILD_MDRUN_ONLY=ON  -DGMX_BUILD_OWN_FFTW=ON \
          -DCMAKE_INSTALL_PREFIX=/lustre/home/t01/auser/software/GROMACS/2020.2-gcc9
make -j 8 install
```

Configure and build the serial, single-precision build
-------------------------------------------------------

The serial build is required for the GROMACS analysis utilities.

Create a build directory in the source tree

```bash
cd gromacs-2020.2
mkdir build
cd build
```

Use CMake to configure the build and then build and install. Remember to set the install 
prefix to somewhere you have permission to write to.

```bash
cmake ../ -DGMX_MPI=OFF -DGMX_OPENMP=ON -DGMX_GPU=OFF -DGMX_X11=OFF -DGMX_DOUBLE=OFF \
          -DGMX_BUILD_OWN_FFTW=ON \
          -DCMAKE_INSTALL_PREFIX=/lustre/home/t01/auser/software/GROMACS/2020.2-gcc9
make -j 8 install
```

