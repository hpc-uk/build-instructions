Build Instructions for QE 6.4.1 on ARCHER
-----------------------------------------

For version 6.4.1 on ARCHER using the Intel compilers

```bash
tar xzf q-e-qe-6.4.1.tar.gz
cd q-e-qe-6.4.1
module swap PrgEnv-cray PrgEnv-intel
export CC=cc
export FC=ftn
export F77=ftn
export F90=ftn

./configure --prefix=/work/y07/y07/cse/espresso/6.4.1
```

Modify make options:

```bash
cp make.inc make.inc-orig
emacs -nw make.inc
```

Changes:

```
LDFLAGS=-static -I$(INTEL_PATH)/mkl/include/  -I$(INTEL_PATH)/mkl/include/intel64/lp64/

BLAS_LIBS=$(INTEL_PATH)/mkl/lib/intel64/libmkl_sequential.a $(INTEL_PATH)/mkl/lib/intel64/libmkl_blacs_intelmpi_lp64.a \
-Wl,--end-group

LAPACK_LIBS=$(INTEL_PATH)/mkl/lib/intel64/libmkl_intel_lp64.a $(INTEL_PATH)/mkl/lib/intel64/libmkl_core.a

SCALAPACK_LIBS=$(INTEL_PATH)/mkl/lib/intel64/libmkl_scalapack_lp64.a -Wl,--start-group

FFT_LIBS=
```

Build:

```
make all
```

`/work/y07/y07/cse/espresso/q-e-qe-6.4.1/bin` exists now


