Instructions for compiling GROMACS 2019 for AMD Rome using AOCC 2.0 compilers
================================================================================

These instructions are for compiling GROMACS 2019 on and AMD Rome system using the AOCC (AMD Optimising Compiler Collection, clang) compilers 2.0.

These instructions build the thread MPI version for single node parallelism only.


Download and Unpack the GROMACS source code
-------------------------------------------

Download and unpack the source

```bash
wget http://ftp.gromacs.org/pub/gromacs/gromacs-2019.3.tar.gz
tar -xvf gromacs-2019.3.tar.gz
```

Setup correct modules
---------------------

Load the AOCC 2.0 compiler module

```bash
module load amd/aocc/2.0
```

Configure and build the single-precision build
----------------------------------------------

Create a build directory in the source tree

```bash
cd gromacs-2019.3
mkdir build_threadmpi
cd build_threadmpi
```

Set additional options for the build (to enforce compilers and use the AMD Optimised FFTW 3 installation):

```bash
CMAKE_OPTS="-DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++"
CMAKE_OPTS="$CMAKE_OPTS CMAKE_C_FLAGS='-march=znver2' -DFFTWF_LIBRARY=/cm/shared/apps/amd/aocl/2.0/amd-fftw/lib/libfftw3f.a"
CMAKE_OPTS="$CMAKE_OPTS -DFFTWF_INCLUDE_DIR=/cm/shared/apps/amd/aocl/2.0/amd-fftw/include"

```

Use CMake to configure the build and then build

```bash
cmake ../ \
   -DCMAKE_BUILD_TYPE=Release \
   -DGMX_OPENMP=ON \
   -DGMX_MPI=OFF \
   -DGMX_GPU=OFF \
   -DGMX_DOUBLE=OFF \
   -DGMX_BUILD_MDRUN_ONLY=ON \
   -DGMX_PREFER_STATIC_LIBS=ON \
   $CMAKE_OPTS

make -j 8
```
Once built, the GROMACS binary is available as `mdrun` at `gromacs-2019.3/build_threadmpi/bin`. 

