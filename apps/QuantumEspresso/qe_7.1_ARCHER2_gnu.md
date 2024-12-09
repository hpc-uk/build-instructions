Build Instructions for QE 7.1 on ARCHER2
-----------------------------------------

Using the GNU 8.3.3 Programming Environment, GCC 11.2.0 compilers. 

Set-up environment: 
-------------------
```bash
PRFX=/path/to/work  # e.g., PRFX=/work/<project-code>/<project-code>/<username>/software
cd ${PRFX}

PACKAGE_LABEL=quantum-espresso
PACKAGE_LABEL_SHORT=qe
PACKAGE_VERSION=7.1
PROGRAMMING_ENV=gnu
PACKAGE_ROOT=${PRFX}/${PACKAGE_LABEL}
PACKAGE_INSTALL=${PACKAGE_ROOT}/${PACKAGE_LABEL_SHORT}-${PACKAGE_VERSION}-${PROGRAMMING_ENV}

mkdir -p ${PACKAGE_ROOT}
cd ${PACKAGE_ROOT}

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
```

The Quantum-Espresso source code can be found on the website: [https://www.quantum-espresso.org/](https://www.quantum-espresso.org/). Download locally and transfer to `${PACKAGE_ROOT}` on ARCHER2. 

Unpack: 
```bash 
tar -xvf ${PACKAGE_LABEL_SHORT}-${PACKAGE_VERSION}-ReleasePack.tar.gz
mv ${PACKAGE_LABEL_SHORT}-${PACKAGE_VERSION} ${PACKAGE_INSTALL}
cd ${PACKAGE_INSTALL}
```

Build:
-------
```bash 
MPIF90=ftn F90=ftn ./configure --prefix=${PACKAGE_INSTALL} --enable-parallel --enable-openmp --with-scalapack=yes
```

In `make.inc` change `DFLAGS` to:
```bash
DFLAGS         =  -D__MPI -D__SCALAPACK -D__FFTW3 -D__HDF5

... 

FFLAGS         = -O3 -g -fallow-argument-mismatch -fopenmp -ffpe-summary=none
```

Build:
```bash
make all
```

Find the Quantum Espresso installation in: `${PACKAGE_INSTALL}/bin`


Testing:
---------

We can run a series of tests/benchmarks using the data sets for QE benchmarks (referenced [here](https://www.quantum-espresso.org/benchmarks/)). 

```bash
cd ${PACKAGE_INSTALL}
git clone https://github.com/QEF/benchmarks.git
```

Available tests and execution times:  
* `AUSURF112` - 2 minutes on 2 x 128-core ARCHER2 nodes.
* `PSIWAT` - 4 minutes on 4 x 128-core ARCHER2 nodes.
* `other-inputs/CuO` - 2 minutes on 2 x 128-core ARCHER2 node.
* `other-inputs/water` - 59 minutes on 8 x 123-core ARCHER2 nodes.


Example submission script for PSIWAT: 
```bash
#!/bin/bash

#SBATCH --job-name=QE_CPU_TEST
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=128
#SBATCH --cpus-per-task=1
#SBATCH --time=00:20:00

# Replace [budget code] below with your project code (e.g. t01)
#SBATCH --account=[budget code]
#SBATCH --partition=standard
#SBATCH --qos=standard

# Update this: 
PRFX=/path/to/work  # e.g., PRFX=/work/<project-code>/<project-code>/<username>/software

PACKAGE_LABEL=quantum-espresso
PACKAGE_LABEL_SHORT=qe
PACKAGE_VERSION=7.1
PROGRAMMING_ENV=gnu
PACKAGE_ROOT=${PRFX}/${PACKAGE_LABEL}
PACKAGE_INSTALL=${PACKAGE_ROOT}/${PACKAGE_LABEL_SHORT}-${PACKAGE_VERSION}-${PROGRAMMING_ENV}

export OMP_NUM_THREADS=1
export PATH=$PATH:${PACKAGE_INSTALL}/bin
export ESPRESSO_PSEUDO=${PACKAGE_INSTALL}/benchmarks/PSIWAT

time srun --cpu-freq=2250000 pw.x -i psiwat.in
```
