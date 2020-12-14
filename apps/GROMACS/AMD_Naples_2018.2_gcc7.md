Instructions for compiling GROMACS 2018 for AMD Naples (EPYC) using GCC 7 compilers
===================================================================================

Download and Unpack the GROMACS source code
-------------------------------------------

Download and unpack the source

```bash
wget http://ftp.gromacs.org/pub/gromacs/gromacs-2018.2.tar.gz
tar -xvf gromacs-2018.2.tar.gz
```

Setup correct modules
---------------------

```bash
module use /opt/amd/modulefiles/AMD/
module load gcc/7.2.0
module load OpenMPI/2.1.1-gcc7.2.0 
module load OpenBLAS/0.2.20/gcc/4.8.5/threads
```

Prerequisites
-------------

You may also need to build other prerequisites: FFTW, FFTW single precision and Python 2 (if they are not already available).

Configure and build the single-precision build
----------------------------------------------

Create a build directory in the source tree

```bash
cd gromacs-2018.2
mkdir build
cd build
```

Set additional options for the build:

```bash
export FLAGS="-dynamic -O3 -ftree-vectorize -funroll-loops "
```

Use CMake to configure the build and then build

```bash
cmake ../ -DGMX_MPI=ON -DGMX_OPENMP=ON -DGMX_GPU=OFF -DGMX_X11=OFF -DGMX_DOUBLE=OFF \
-DCMAKE_C_FLAGS="$FLAGS" -DCMAKE_CXX_FLAGS="$FLAGS" \
-DGMX_SIMD=Reference -DGMX_BUILD_MDRUN_ONLY=ON \
-DGMX_FFT_LIBRARY=fftw3  -DCMAKE_PREFIX_PATH=“/scratch_lustre_DDN7k/xguox/fftw/install-gnu7.2.0-single/lib” \
-DFFTWF_INCLUDE_DIR='/scratch_lustre_DDN7k/xguox/fftw/install-gnu7.2.0-single/include'

make -j 8
```
Once built, the GROMACS binary is available as `gmx ` at `gromacs-2018.2/build/bin`. 

