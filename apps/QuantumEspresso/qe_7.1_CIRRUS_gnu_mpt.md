Build Instructions for QE 7.1 on Cirrus
-----------------------------------------

Building Quantum Espresso 7.1 on Cirrus. Instructions use the GNU Programming Environment, at time of writing (December 2024) this corresponds to `gcc/10.2.0` and `MPT/2.25`.

Set-up paths: 
-------------------
```bash
PRFX=/path/to/work  # e.g., PRFX=/work/<project-code>/<project-code>/<username>/software
cd ${PRFX}

PACKAGE=quantum-espresso
PACKAGE_VERSION=7.1
PE_VERSION=gcc10.2
MPI_VERSION=mpt2.25
PACKAGE_INSTALL=${PRFX}/${PACKAGE}/qe-${PACKAGE_VERSION}-${PE_VERSION}-${MPI_VERSION}

mkdir -p ${PRFX}/${PACKAGE}
cd ${PRFX}/${PACKAGE}
```

Set-up environment:
-------------------

```bash 
module load mpt
module load gcc
module load cmake
module load intel-20.4/cmkl
module load fftw/3.3.10-gcc10.2-mpt2.25
module load hdf5parallel/1.14.3-gcc10-mpt225
```

The Quantum-Espresso source code can be found on the website: [https://www.quantum-espresso.org/](https://www.quantum-espresso.org/). Download locally and transfer to `${PACKAGE_ROOT}` on ARCHER2. 

Unpack: 
```bash 
cd ${PRFX}/${PACKAGE}
tar -xvf qe-7.1-ReleasePack.tar.gz
cd qe-7.1
```

Build:
-------
```bash 
mkdir build && cd build
cmake -DCMAKE_C_COMPILER=mpicc -DCMAKE_Fortran_COMPILER=mpif90 -DCMAKE_INSTALL_PREFIX=${PACKAGE_INSTALL} -DCMAKE_Fortran_FLAGS="-ffpe-summary=none" ..

make -j 8 
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

Example submission script for `AUSURF112` - Execution time is ~ 3 minutes on 2 x 36-core Cirrus CPU nodes: 
```bash
#!/bin/bash

#SBATCH --job-name=qe_cpu_test
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=36
#SBATCH --cpus-per-task=1
#SBATCH --time=00:20:00
#SBATCH --exclusive 

#SBATCH --account=z04
#SBATCH --partition=standard
#SBATCH --qos=standard

PRFX=/path/to/work

module load mpt
module load gcc
module load intel-20.4/cmkl

PACKAGE=quantum-espresso
PACKAGE_VERSION=7.1
PE_VERSION=gcc10.2
MPI_VERSION=mpt2.25
PACKAGE_INSTALL=${PRFX}/${PACKAGE}/qe-${PACKAGE_VERSION}-${PE_VERSION}-${MPI_VERSION}

export OMP_NUM_THREADS=1
export PATH=$PATH:${PACKAGE_INSTALL}/bin
export ESPRESSO_PSEUDO=${PACKAGE_INSTALL}/benchmarks/AUSURF112

time srun pw.x -i ausurf.in
```

To use this for other tests, change the input after `-i` and the path to the psuedo-potentials in `export ESPRESSO_PSEUDO`. 
