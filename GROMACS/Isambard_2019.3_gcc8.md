Instructions for compiling GROMACS 2019.3 for Isambard using GCC 8 compilers
==========================================================================

These instructions are for compiling GROMACS 2019.3 on Isambard (Cray XC50, Marvell TunderX2 Arm64 processors)
using the GCC 8.x compilers.


Download and Unpack the GROMACS source code
-------------------------------------------

Download and unpack the source

```bash
wget http://ftp.gromacs.org/pub/gromacs/gromacs-2019.3.tar.gz
tar -xvf gromacs-2019.3.tar.gz
```

Setup correct modules
---------------------

Switch to the GNU programming environment:

```bash
module swap PrgEnv-cray PrgEnv-gnu
```

and load the fftw and CMake modules:

```bash
module load cray-fftw
```

Configure and build the parallel, single-precision build
--------------------------------------------------------

Create a build directory in the source tree

```bash
cd gromacs-2019.3
mkdir build_mpi
cd build_mpi
```

Set the environment variables for the CMake build.

```bash
export CXX=CC
export CC=cc
```

Use CMake to configure the build and then build and install. Remember to set the install 
prefix to somewhere you have permission to write to.

```bash
cmake ../ -DGMX_MPI=ON -DGMX_OPENMP=ON -DGMX_GPU=OFF -DGMX_X11=OFF -DGMX_DOUBLE=OFF \
          -DGMX_BUILD_MDRUN_ONLY=ON -DGMX_BUILD_OWN_FFTW=ON \
          -DCMAKE_INSTALL_PREFIX=/home/user/gmx/2019.3-gcc8
make -j 8 install
```

