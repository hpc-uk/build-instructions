Build Instructions for QE 6.6 on ARCHER2
-----------------------------------------

For version 6.6 on ARCHER using the GCC compilers

```bash
module restore PrgEnv-gnu
module load cray-libsci
module load cray-fftw
tar -xvf qe-6.6.tar.gz
cd q-e-qe-6.6
export CC=cc
export FC=ftn
export F77=ftn
export F90=ftn
./configure --prefix=${PATH_TO}/q-e-qe-6.6
```

Build:

```bash
make all
```

`${PATH_TO}/q-e-qe-6.6/bin` exists now

..NOTE:: probably worth setting ESPRESSO_PSEUDO to
${PATH_TO}/q-e-qe-6.6/pseudo as default
