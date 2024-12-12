Build Instructions for QE 6.8 on ARCHER2
=========================================

Building Quantum Espresso 7.1 on ARCHER2. Instructions use the GNU Programming Environment, at time of writing (December 2024) this corresponds to `gcc/11.2.0` and `PrgEnv-gnu/8.3.3`.

Set-up paths: 
-------------------
```bash
PRFX=/path/to/work  # e.g., PRFX=/work/<project-code>/<project-code>/<username>/software
cd ${PRFX}

PACKAGE=quantum_espresso
PACKAGE_VERSION=6.8
PACKAGE_INSTALL=${PRFX}/${PACKAGE}/${PACKAGE_VERSION}

mkdir -p ${PACKAGE_ROOT}
cd ${PACKAGE_ROOT}
```

Set-up environment:
-------------------

```bash 
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
cd ${PACKAGE_ROOT}
tar -xvf qe-6.8-ReleasePack.tar.gz
cd qe-6.8
```

Build:
-------
```bash 
MPIF90=ftn F90=ftn ./configure --prefix=${PACKAGE_INSTALL} --enable-parallel --with-scalapack=yes
```

In `make.inc` change `DFLAGS` and `FFLAGS` to:

```bash
DFLAGS         =  -D__MPI -D__SCALAPACK -D__FFTW3 -D__HDF5
 
... 

FFLAGS         = -O3 -g -fallow-argument-mismatch -fopenmp -ffpe-summary=none

```

And be careful to check that `gfortran` has been replaced by `ftn` in all cases. 

Build and install, including EPW:
```bash
make -j 8 all
make -j 8 epw
make install
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
* `other-inputs/water` - 59 minutes on 8 x 128-core ARCHER2 nodes.


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

PACKAGE_LABEL=quantum_espresso
PACKAGE_VERSION=7.1
PACKAGE_INSTALL=${PRFX}/${PACKAGE}/${PACKAGE_VERSION}

export OMP_NUM_THREADS=1
export PATH=$PATH:${PACKAGE_INSTALL}/bin
export ESPRESSO_PSEUDO=${PACKAGE_INSTALL}/benchmarks/PSIWAT

time srun --cpu-freq=2250000 pw.x -i psiwat.in
```

To use this for other tests, change the input after `-i` and the path to the psuedo-potentials in `export ESPRESSO_PSEUDO`. 
