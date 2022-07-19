Build Instructions for QE 6.8 on ARCHER2
-----------------------------------------

For version 7.0 on ARCHER using the GCC compilers

```bash
wget https://gitlab.com/QEF/q-e/-/archive/qe-7.0/q-e-qe-7.0.tar.gz
tar -zxvf q-e-qe-7.0.tar.gz
mv q-e-qe-7.0 q-e_7.0

sh set_environment.sh 

./configure --enable-parallel --enable-openmp --with-scalapack=yes
```

In `make.inc` `make.inc` and change `DFLAGS` to:

```bash
DFLAGS         =  -D__MPI -D__SCALAPACK -D__FFTW3 -D__HDF5 
```
Build 

```bash
make -j 4 pw
```
