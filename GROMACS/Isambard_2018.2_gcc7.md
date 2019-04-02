Instructions for compiling GROMACS 2018 for Isambard (Arm) using GCC 7 compilers
================================================================================

These instructions are for compiling GROMACS 2018.2 on Isambard (GW4), Cray XC50
with Arm64 processors using the GCC 7.x compilers.


Download and Unpack the GROMACS source code
-------------------------------------------

Download and unpack the source

```bash
wget http://ftp.gromacs.org/pub/gromacs/gromacs-2018.2.tar.gz
tar -xvf gromacs-2018.2.tar.gz
```

Setup correct modules
---------------------

Make the Arm tools modules available and clean environment:

```bash
module use /lustre/projects/bristol/modules-arm/modulefiles
module purge
```

Load the GCC 7.x compiler module

```bash
module load arm/gcc/7.1.0
```

Load the cmake module:

```bash
module load cmake
```

Configure and build the single-precision build
----------------------------------------------

Create a build directory in the source tree

```bash
cd gromacs-2018.2
mkdir build
cd build
```

Set additional options for the build (to enforce compilers and use the Cray FFTW 3 installation):

```bash
CMAKE_OPTS="-DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++"
CMAKE_OPTS="$CMAKE_OPTS -DFFTWF_LIBRARY=/opt/cray/pe/fftw/3.3.6.3/arm_thunderx2/lib/libfftw3f.a"
CMAKE_OPTS="$CMAKE_OPTS -DFFTWF_INCLUDE_DIR=/opt/cray/pe/fftw/3.3.6.3/arm_thunderx2/include"

```

Use CMake to configure the build and then build

```bash
cmake ../ \
   -DCMAKE_BUILD_TYPE=Release \
   -DGMX_OPENMP=ON \
   -DGMX_MPI=OFF \
   -DGMX_GPU=OFF \
   -DGMX_DOUBLE=OFF \
   $CMAKE_OPTS

make -j 8
```
Once built, the GROMACS binary is available as `gmx ` at `gromacs-2018.2/build/bin`. 

