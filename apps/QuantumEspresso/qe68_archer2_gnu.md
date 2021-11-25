Build Instructions for QE 6.8 on ARCHER2
-----------------------------------------

For version 6.8 on ARCHER using the GCC compilers

```bash
wget https://github.com/QEF/q-e/archive/qe-6.8.tar.gz
tar -xvf qe-6.8.tar.gz
cd q-e-qe-6.8

module load PrgEnv-gnu
module load cray-fftw cray-hdf5-parallel

export CC=cc
export FC=ftn
export F77=ftn
export F90=ftn

export BLAS_LIBS=" "
export LAPACK_LIBS=" "
export SCALAPACK_LIBS=" "
export FFT_LIBS=" "

./configure --prefix=${PATH_TO}/q-e-qe-6.8 --enable-parallel --with-scalapack=yes
```

In `make.inc` `make.inc` and change `DFLAGS` to:

```bash
DFLAGS         =  -D__FFTW3 -D__HDF5 -D__MPI -D__SCALAPACK -Duse_beef
```
Build and install, including EPW:

```bash
make -j 8 all
make -j 8 epw
make install
```

`${PATH_TO}/q-e-qe-6.8/bin` exists now

NOTE: probably worth setting `ESPRESSO_PSEUDO` to
`${PATH_TO}/q-e-qe-6.8/pseudo` as default.
