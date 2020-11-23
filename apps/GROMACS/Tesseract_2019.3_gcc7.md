Instructions for compiling GROMACS 2019.3 for Tesseract using GCC 7 compilers
===============================================================================

These instructions are for compiling GROMACS 2019.4 on Tesseract (DiRAC Extreme
Scaling, Intel Skylake Silver) using the GCC 7.x compilers.

Download and Unpack the GROMACS source code
-------------------------------------------

Download and unpack the source

```bash
wget http://ftp.gromacs.org/pub/gromacs/gromacs-2019.3.tar.gz
tar -xvf gromacs-2019.3.tar.gz
```

Setup correct modules
---------------------

Load the GCC 7.x compiler module

```bash
module load gcc/7.3.0
```

Load the cmake module:

```bash
module load cmake/3.11.2
```

Load the MPI module:

```bash
module load intel-mpi-18/18.1.163
```

Configure and build the parallel, single-precision build
--------------------------------------------------------

Create a build directory in the source tree

```bash
cd gromacs-2019.3
mkdir build_mpi
cd build_mpi
```

Use CMake to configure the build and then build.

```bash
cmake ../ -DGMX_MPI=ON -DGMX_OPENMP=ON -DGMX_GPU=OFF -DGMX_X11=OFF -DGMX_DOUBLE=OFF \
          -DGMX_BUILD_MDRUN_ONLY=ON  -DGMX_BUILD_OWN_FFTW=ON 
make -j 8
```

The exectuable will be in the `bin` directory and will be called `mdrun_mpi`


