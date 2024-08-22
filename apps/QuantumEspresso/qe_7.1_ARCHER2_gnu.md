Build Instructions for QE 7.1 on ARCHER2
-----------------------------------------

Using the GNU 8.3.3 Programming Environment, GCC 11.2.0 compilers. 

Obtain the source code from: https://www.quantum-espresso.org/download-page/. Transport to `/work` on ARCHER2.

```bash
PRFX=/path/to/work
cd ${PRFX}

tar -xvf qe-7.1-ReleasePack.tar.gz
cd qe-7.1

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

MPIF90=ftn F90=ftn ./configure --prefix=${PRFX}/qe-7.1 --enable-parallel --enable-openmp --with-scalapack=yes
```

In `make.inc` change `DFLAGS` to:

```bash
DFLAGS         =  -D__MPI -D__SCALAPACK -D__FFTW3 -D__HDF5
```

Build:
```bash
make all
make install
```

`${PRFX}/qe-7.1/bin` exists now


Simple Testing:
----------------

```bash
cd ${PRFX}
git clone https://github.com/QEF/benchmarks.git
cd benchmarks/other-inputs/CuO/
```

```bash
#!/bin/bash

#SBATCH --job-name=qe_cpu_test
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=128
#SBATCH --cpus-per-task=1
#SBATCH --time=00:20:00

# Replace [budget code] below with your project code (e.g. t01)
#SBATCH --account=[budget code]
#SBATCH --partition=standard
#SBATCH --qos=standard

module swap PrgEnv-cray PrgEnv-gnu 
module load cray-fftw
module load cray-hdf5-parallel

# Update this: 
PRFX=/path/to/work

export OMP_NUM_THREADS=1
export ESPRESSO_PSEUDO=${PRFX}/benchmarks/other-inputs/CuO/psuedo/
export PATH=$PATH:${PRFX}/qe-7.1/bin

time srun --cpu-freq=2250000 pw.x -i 1526990.in
```
