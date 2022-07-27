Build Instructions for QE 7.1 on ARCHER2
-----------------------------------------

For version 7.1 on ARCHER using the GCC compilers

```bash
wget https://gitlab.com/QEF/q-e/-/archive/qe-7.1/q-e-qe-7.1.tar.gz
tar -zxvf q-e-qe-7.1.tar.gz
mv q-e-qe-7.1 q-e_7.1  
cd q-e_7.1

module load PrgEnv-gnu
module load cpe/21.09 
module load cray-fftw cray-hdf5-parallel

export LD_LIBRARY_PATH=$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH

export CC=cc
export FC=ftn
export F77=ftn
export F90=ftn

export BLAS_LIBS=" "
export LAPACK_LIBS=" "
export SCALAPACK_LIBS=" "
export FFT_LIBS=" "

./configure --enable-parallel --enable-openmp --with-scalapack=yes
```

In `make.inc` change `DFLAGS` to:

```bash
DFLAGS         =  -D__MPI -D__SCALAPACK -D__FFTW3 -D__HDF5 
```
Build 

```bash
make -j 4 pw
```

At runtime:  
"""
module load cpe/21.09 
module load cray-fftw cray-hdf5-parallel
export LD_LIBRARY_PATH=$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH
"""
