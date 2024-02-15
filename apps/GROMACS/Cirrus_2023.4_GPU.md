Instructions for compiling GROMACS 2023.4 for Cirrus using GCC 12.3 and Intel MPI 20.4
======================================================================================

These instructions are for compiling GROMACS 2022.4 on [Cirrus](https://www.cirrus.ac.uk) using the GCC 12 compilers.

Download and Unpack the GROMACS source code
-------------------------------------------

Download and unpack the source

```bash
wget http://ftp.gromacs.org/pub/gromacs/gromacs-2023.4.tar.gz
tar -xvf gromacs-2023.4.tar.gz
```

Setup correct modules and build environment
-------------------------------------------

```
  module load gcc/12.3.0-offload
  module load intel-20.4/mpi
  module load nvidia/nvhpc-nompi/22.2
  module load cmake/3.25.2
  module load intel-20.4/cmkl
  export CC=gcc
  export CXX=g++
```

Configure and build the parallel, single-precision build
--------------------------------------------------------

Create a build directory in the source tree

```bash
cd /path/to/gromacs-2023.4
mkdir build_mpi
cd build_mpi
```

Use CMake to configure the build and then build and install. Remember to set the install 
prefix to somewhere you have permission to write to.

```bash
cmake ../ 
      -D CMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ \
      -D MPI_C_COMPILER=mpicc -DMPI_CXX_COMPILER=mpicxx \
      -D GMX_MPI=ON -DGMX_OPENMP=ON -DGMX_GPU=OFF \
      -D GMX_X11=OFF -DGMX_DOUBLE=OFF             \
      -D GMX_BUILD_OWN_FFTW=ON                    \
      -D CMAKE_INSTALL_PREFIX=/work/y07/shared/cirrus-software/GROMACS/2023.4

make -j 8
make install
```



```
  cmake .. -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ \
        -DMPI_C_COMPILER=mpicc -DMPI_CXX_COMPILER=mpicxx \
        -DGMX_MPI=ON -DGMX_OPENMP=ON -DGMX_X11=OFF -DGMX_DOUBLE=OFF \
        -DGMX_BUILD_OWN_FFTW=on -DGMX_GPU=CUDA \
        -DCUDA_cufft_LIBRARY=${NVHPC_ROOT}/math_libs/11.6/targets/x86_64-linux/lib/libcufft.so \
        -DCUDA_CUDART_LIBRARY=${NVHPC_ROOT}/cuda/11.6/targets/x86_64-linux/lib/libcudart.so \
        -DCUDA_TOOLKIT_INCLUDE=${NVHPC_ROOT}/cuda/11.6/targets/x86_64-linux/include \
        -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
        -DBUILD_SHARED_LIBS=yes \
        -DGMX_INSTALL_NBLIB_API=OFF \
        -DBLAS_LIBRARIES="${MKLROOT}/lib/intel64_lin/libmkl_gf_lp64.so;${MKLROOT}/lib/intel64_lin/libmkl_core.so;${MKLROOT}/lib/intel64_lin/libmkl_gnu_thread.so" \
        -DLAPACK_LIBRARIES="${MKLROOT}/lib/intel64_lin/libmkl_gf_lp64.so;${MKLROOT}/lib/intel64_lin/libmkl_core.so;${MKLROOT}/lib/intel64_lin/libmkl_gnu_thread.so" \
        -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}
        
  make -j 8 install
```
