Build Instructions for QE 6.5 on ARCHER2 TDS
-----------------------------------------

For version 6.5 on ARCHER using the GCC compilers

```bash
module swap PrgEnv-cray PrgEnv-gnu
module load cray-libsci
module load cray-fftw

tar -xvf qe-6.5.tar.gz
cd q-e-qe-6.5

export CC=cc
export FC=ftn
export F77=ftn
export F90=ftn

./configure --prefix=${PATH_TO}/q-e-qe-6.5
```

Build:

```bash
make all
```

`${PATH_TO}/q-e-qe-6.4.1/bin` exists now

..NOTE:: probably worth setting ESPRESSO_PSEUDO to
${PATH_TO}/q-e-qe-6.4.1/pseudo as default
