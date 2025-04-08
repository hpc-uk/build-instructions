Build Instructions for QE 7.3.1 on ARCHER2
-----------------------------------------

Building Quantum Espresso 7.3.1 on ARCHER2. Instructions use the GNU Programming Environment, at time of writing (December 2024) this corresponds to `gcc/11.2.0` and `PrgEnv-gnu/8.3.3`.

Set-up paths: 
-------------------
```bash
PRFX=/path/to/work  # e.g., PRFX=/work/<project-code>/<project-code>/<username>/software
cd ${PRFX}

PACKAGE=quantum_espresso
PACKAGE_VERSION=7.4.1
PACKAGE_INSTALL=${PRFX}/${PACKAGE}/${PACKAGE_VERSION}

mkdir -p ${PRFX}/${PACKAGE}
cd ${PRFX}/${PACKAGE}
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

The Quantum-Espresso source code can be found on the website: [https://www.quantum-espresso.org/](https://www.quantum-espresso.org/). Or via github:

```bash 
cd ${PRFX}/${PACKAGE}

git clone https://github.com/QEF/q-e
mv q-e q-e-${PACKAGE_VERSION}
cd q-e-${PACKAGE_VERSION}
git checkout qe-${PACKAGE_VERSION}
```

Build: 
--------

```bash 
mkdir build && cd build
cmake -DCMAKE_C_COMPILER=cc -DCMAKE_Fortran_COMPILER=ftn -DCMAKE_INSTALL_PREFIX=${PACKAGE_INSTALL} -DCMAKE_Fortran_FLAGS="-ffpe-summary=none" ..

make -j 8 
make install
```

Find the Quantum Espresso installation in: `${PACKAGE_INSTALL}/bin`


Testing:
---------

We can run a series of tests/benchmarks using the data sets for QE benchmarks (referenced [here](https://www.quantum-espresso.org/benchmarks/)). 

```bash
cd ${PRFX}/${PACKAGE}
git clone https://github.com/QEF/benchmarks.git
```

Available tests and execution times:  
* `AUSURF112` - 1 min 40s 1 x 128-core ARCHER2 node.
* `PSIWAT` - 3 mins 30s 4 x 128-core ARCHER2 nodes.


Example submission script for PSIWAT: 
```bash
#!/bin/bash

#SBATCH --job-name=QE_CPU_TEST
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=128
#SBATCH --cpus-per-task=1
#SBATCH --time=00:20:00
#SBATCH --output=slurm-qe-7.1-%j.out

# Replace [budget code] below with your project code (e.g. t01)
#SBATCH --account=[budget code]
#SBATCH --partition=standard
#SBATCH --qos=standard

# Update this: 
PRFX=/path/to/work  # e.g., PRFX=/work/<project-code>/<project-code>/<username>/software
PACKAGE=quantum_espresso
PACKAGE_VERSION=7.4.1
PACKAGE_INSTALL=${PRFX}/${PACKAGE}/${PACKAGE_VERSION}

# Use source build: 
export PATH=$PATH:${PACKAGE_INSTALL}/bin

export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export ESPRESSO_PSEUDO=${PACKAGE_INSTALL}/benchmarks/PSIWAT

time srun --cpu-freq=2250000 pw.x -i psiwat.in
```

To use this for other tests, change the input after `-i` and the path to the psuedo-potentials in `export ESPRESSO_PSEUDO`. 
