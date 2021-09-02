Build Instructions for QE 6.6 on ARCHER2
-----------------------------------------

For version 6.6 on ARCHER using the GCC compilers

```bash
wget https://github.com/QEF/q-e/archive/qe-6.6.tar.gz
tar -xvf qe-6.6.tar.gz
cd q-e-qe-6.6

module restore PrgEnv-gnu
module load cray-libsci cray-fftw cray-hdf5-parallel
module load cpe/21.03

export CC=cc
export FC=ftn
export F77=ftn
export F90=ftn

export BLAS_LIBS=" "
export LAPACK_LIBS=" "
export SCALAPACK_LIBS=" "
export FFT_LIBS=" "

./configure --prefix=${PATH_TO}/q-e-qe-6.6 --enable-parallel --with-scalapack=yes
```

In `make.inc` `make.inc` and change `DFLAGS` to:

```bash
DFLAGS         =  -D__FFTW3 -D__HDF5 -D__MPI -D__SCALAPACK -Duse_beef
```
Build and install:

```bash
make -j 8 all
make install
```

`${PATH_TO}/q-e-qe-6.6/bin` exists now

NOTE: probably worth setting `ESPRESSO_PSEUDO` to
`${PATH_TO}/q-e-qe-6.6/pseudo` as default.
