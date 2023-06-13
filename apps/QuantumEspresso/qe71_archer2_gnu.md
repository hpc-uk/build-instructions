Build Instructions for QE 7.1 on ARCHER2
-----------------------------------------

For version 7.1 on ARCHER2 using the GCC compilers and the 22.04 CPE.

```bash
wget https://gitlab.com/QEF/q-e/-/archive/qe-7.1/q-e-qe-7.1.tar.gz
tar -zxvf q-e-qe-7.1.tar.gz
cd q-e-qe-7.1

module load PrgEnv-gnu
# module load cpe/22.04
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
```

Remember to change the prefix location:
```bash
./configure --enable-parallel --enable-openmp --with-scalapack=yes --prefix=/path/to/desired/install/location
```

In `make.inc` change `DFLAGS` in Line 43 to:

```bash
DFLAGS         =  -D__MPI -D__SCALAPACK -D__FFTW3 -D__HDF5
```

Replace explicit compilers with the compiler wrapper in lines 88, 89, 133 to:
```bash
ftn
```

In wannier90-3.1.0/make.inc change the `mpif90` compiler to the ftn wrapper on line 7.

Build:
```bash
make all
make install
```

Some simple testing using the QE benchmark's repo:

```bash
git clone https://github.com/electronic-structure/benchmarks.git
cd benchmarks/Fe_Graphene-scf/

```

```bash
#!/bin/bash

#SBATCH --job-name=qe_test
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=128
#SBATCH --cpus-per-task=1
#SBATCH --time=00:20:00

# Replace [budget code] below with your project code (e.g. t01)
#SBATCH --account=[budget code]
#SBATCH --partition=standard
#SBATCH --qos=standard

# Load the relevant Quantum Espresso module
# module load quantum_espresso/7.1

export OMP_NUM_THREADS=1
export PATH=$PATH:/path/to/qe/bin
export ESPRESSO_PSEUDO=/path/to/benchmarks/Fe_Graphene-scf/pseudo

time srun pw.x -i pw.in
```
