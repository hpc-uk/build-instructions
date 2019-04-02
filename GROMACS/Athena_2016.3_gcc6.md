Instructions for compiling GROMACS 2016.3 for Athena (HPC Mid+) using GCC 6 compilers
=====================================================================================

These instructions are for compiling GROMACS 2016.3 on Athena (HPC Mid+) using the GCC 6 compilers.


Download and Unpack the GROMACS source code
-------------------------------------------

Download and unpack the source

```bash
wget http://ftp.gromacs.org/pub/gromacs/gromacs-2016.3.tar.gz
tar -xvf gromacs-2016.3.tar.gz
```

Setup correct modules
---------------------

Load the compiler and MPI modules

```bash
module load gcc/6.3.0/1 
module load intel/mpi/64/2017.2.174
```

Load the cmake module:

```bash
module load cmake
```

Configure and build the parallel, single-precision build
--------------------------------------------------------

Create a build directory in the source tree

```bash
cd gromacs-2016.3
mkdir build_mpi
cd build_mpi
```

Use CMake to configure the build and then build and install. Remember to set the install 
prefix to somewhere you have permission to write to.

```bash
cmake ../ -DGMX_MPI=ON -DGMX_OPENMP=ON -DGMX_GPU=OFF -DGMX_X11=OFF -DGMX_DOUBLE=OFF \
          -DGMX_BUILD_MDRUN_ONLY=ON  -DGMX_BUILD_OWN_FFTW=ON \
          -DCMAKE_INSTALL_PREFIX=/gpfs/home/lboro/aturner/software/GROMACS/2016.3-gcc6
make -j 8 install
```

Configure and build the serial, single-precision build
-------------------------------------------------------

The serial build is required for the GROMACS analysis utilities.

Create a build directory in the source tree

```bash
cd gromacs-2016.3
mkdir build
cd build
```

Use CMake to configure the build and then build and install. Remember to set the install 
prefix to somewhere you have permission to write to.

```bash
cmake ../ -DGMX_MPI=OFF -DGMX_OPENMP=ON -DGMX_GPU=OFF -DGMX_X11=OFF -DGMX_DOUBLE=OFF \
          -DGMX_BUILD_OWN_FFTW=ON \
          -DCMAKE_INSTALL_PREFIX=/gpfs/home/lboro/aturner/software/GROMACS/2016.3-gcc6
make -j 8 install
```

