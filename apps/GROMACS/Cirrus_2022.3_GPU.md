Load modules:

```
  module load nvidia/nvhpc-nompi/22.2
  module load openmpi/4.1.2-cuda-11.6
  module load cmake/3.17.3
  module load intel-19.5/cmkl
  export CC=gcc
  export CXX=g++
```

Set install path:

```
  export INSTALL_PREFIX=<path_to_install>
```

Download and unpack GROMACS:

```
wget https://ftp.gromacs.org/gromacs/gromacs-2022.3.tar.gz
tar -xvf gromacs-2022.3.tar.gz
mkdir gromacs-2022.3/build ; cd gromacs-2022.3/build
```

CMake and build:

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
