Instructions for compiling GROMACS 2016.4 for CSD3 Skylake using GCC 7 compilers
================================================================================

These instructions are for compiling GROMACS 2016.4 on CSD3 Skylake (University of Cambridge)
using the GCC 7.x compilers.


Download and Unpack the GROMACS source code
-------------------------------------------

Download and unpack the source

```bash
wget http://ftp.gromacs.org/pub/gromacs/gromacs-2016.4.tar.gz
tar -xvf gromacs-2016.4.tar.gz
```

Setup correct modules
---------------------

Load the GCC 7.x compiler module

```bash
module load gcc-7.2.0-gcc-4.8.5-pqn7o2k
```

Load the cmake module:

```bash
module load cmake/3.9.4
```

Configure and build the parallel, single-precision build
--------------------------------------------------------

Create a build directory in the source tree

```bash
cd gromacs-2016.4
mkdir build_mpi
cd build_mpi
```

Use CMake to configure the build and then build and install. Remember to set the install 
prefix to somewhere you have permission to write to.

```bash
cmake ../ -DGMX_MPI=ON -DGMX_OPENMP=ON -DGMX_GPU=OFF -DGMX_X11=OFF -DGMX_DOUBLE=OFF \
          -DGMX_BUILD_MDRUN_ONLY=ON  -DGMX_BUILD_OWN_FFTW=ON
make -j 8
```

Configure and build the serial, single-precision build
-------------------------------------------------------

The serial build is required for the GROMACS analysis utilities.

Create a build directory in the source tree

```bash
cd gromacs-2016.4
mkdir build
cd build
```

Use CMake to configure the build and then build.

```bash
cmake ../ -DGMX_MPI=OFF -DGMX_OPENMP=ON -DGMX_GPU=OFF -DGMX_X11=OFF -DGMX_DOUBLE=OFF \
          -DGMX_BUILD_OWN_FFTW=ON
make -j 8
```

