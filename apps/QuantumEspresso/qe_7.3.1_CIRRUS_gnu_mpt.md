Build Instructions for QE 7.3.1 on Cirrus
-----------------------------------------

Using the GCC 10.2.0 compilers and MPT 2.25. 

Obtain the source code from: https://www.quantum-espresso.org/download-page/. Transport to `/work` on ARCHER2.

```bash
PRFX=/path/to/work
cd ${PRFX}

tar -xvf qe-7.3.1-ReleasePack.tar.gz
cd qe-7.3.1

module load mpt
module load gcc
module load cmake
module load intel-20.4/cmkl

mkdir build && cd build
cmake -DCMAKE_C_COMPILER=mpicc -DCMAKE_Fortran_COMPILER=mpif90 -DCMAKE_INSTALL_PREFIX=${PRFX}/qe-7.3.1 ..

```

Build:
```bash
make -j 8 
make install
```

`${PRFX}/qe-7.3.1/bin` exists now


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
#SBATCH --ntasks-per-node=36
#SBATCH --cpus-per-task=1
#SBATCH --time=00:20:00
#SBATCH --exclusive 

#SBATCH --account=z04
#SBATCH --partition=standard
#SBATCH --qos=short

module load mpt
module load gcc
module load intel-20.4/cmkl

# Update this: 
PRFX=/path/to/work

export OMP_NUM_THREADS=1
export ESPRESSO_PSEUDO=${PRFX}/benchmarks/other-inputs/CuO/psuedo/
export PATH=$PATH:${PRFX}/qe-7.3.1/bin

time srun pw.x -i 1526990.in
```