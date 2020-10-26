# FHI-aims

FHI-aims (see, e.g., https://aimsclub.fhi-berlin.mpg.de) is usually compiled
by individual users who first must have obtained a license.

FHI-aims is available to registered users as

```
$  git clone https://aims-git.rz-berlin.mpg.de/aims/FHIaims.git
```

However, here we discuss a bundled release version downloaded as `fhi-aims.200112_2.tgz`.

Untar the bundle (or clone the git) a suitable location on `/work`. Note that we will refer
to the top-level directory as `FHI_AIMS_ROOT`. E.g.,
```
tar xf fhi-aims.200112_2.tgz
cd fhi-aims.200112_2
export FHI_AIMS_ROOT=`pwd`
```

At the time of writing, compilation with `intel-mpi-19/19.0.0.117` should be
avoided. Use `intel-18` or `mpt` as described in the following.

## Intel (may give slightly better performance)

```
tar xf fhi-aims.200112_2.tgz
cd fhi-aims.200112_2
export FHI_AIMS_ROOT=`pwd`

mkdir build-intel
cd build-intel

module load intel-mpi-18
module load intel-compilers-18
module load intel-tools-18

module load cmake

cat >> initial_cache.cmake <<EOF
 set(CMAKE_Fortran_COMPILER mpiifort CACHE STRING "")
set(CMAKE_Fortran_FLAGS "-O3 -ip -fp-model precise" CACHE STRING "")
set(Fortran_MIN_FLAGS "-O0 -ip -fp-model precise" CACHE STRING "")
set(CMAKE_C_COMPILER mpiicc CACHE STRING "")
set(CMAKE_C_FLAGS "-O3 -ip -fp-model precise" CACHE STRING "")
set(USE_SCALAPACK true CACHE BOOL "Use SCALAPACK")
set(CMAKE_EXE_LINKER_FLAGS "-L${MKLROOT}/lib/intel64 -lmkl_scalapack_lp64 -lmkl_
intel_lp64 -lmkl_sequential -lmkl_core -lmkl_blacs_intelmpi_lp64 -lpthread -lm -
ldl" CACHE STRING "")
EOF

cmake -C initial_cache.cmake ..

make -j 8
```

See the accompanying script `install-intel.sh`.

## Gnu/mpt (option)

At the time of writing we have as default `gcc/6.3.0` and `cmake/3.17.3`.

```
module load mpt/2.22
module load gcc/6.3.0
module load intel-tools-19

module load cmake

cat >> initial_cache.cmake <<EOF
set(CMAKE_Fortran_COMPILER mpif90 CACHE STRING "")
set(CMAKE_Fortran_FLAGS "-f90=gfortran -O3 -ffree-line-length-none" CACHE STRING "")
set(Fortran_MIN_FLAGS "-f90=gfortran -O0 -ffree-line-length-none" CACHE STRING "")
set(CMAKE_C_COMPILER mpicc CACHE STRING "")
set(CMAKE_C_FLAGS "-O3" CACHE STRING "")
set(USE_SCALAPACK true CACHE BOOL "Use SCALAPACK")
set(CMAKE_EXE_LINKER_FLAGS "-L${MKLROOT}/lib/intel64 -lmkl_scalapack_lp64 -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lmkl_blacs_sgimpt_lp64 -lpthread -lm -ldl" CACHE STRING "")
EOF

cmake -C initial_cache.cmake ..

```

See the accompanying script `install-gnu.sh`.

## Test job submission

For either build, we can use one of the standard test benchmarks provided

```
${FHI_AIMS_ROOT}/benchmarks/Ac-Lys-Ala19-H/control.in
${FHI_AIMS_ROOT}/benchmarks/Ac-Lys-Ala19-H/geometry.in
```

The results can be compared with one of the reference results provided, e.g.,
in directory:
```
${FHI_AIMS_ROOT}/benchmarks/Ac-Lys-Ala19-H/reference.hydra.48cores
```

Use the following submission script for a 72-core job. The account code
(SBATCH option `--account`) and `FHI_AIMS_ROOT` should be updated
appropriately. Note this is for `build-intel`.

```
#!/bin/bash --login

#SBATCH --exclusive
#SBATCH --nodes=2
#SBATCH --tasks-per-node=36
#SBATCH --cpus-per-task=1

#SBATCH --time=00:20:00

#SBATCH --account=YOUR_ACCOUNT_CODE_HERE
#SBATCH --partition=standard
#SBATCH --qos=standard

module load intel-mpi-18
module load intel-tools-18

# Assume we have installed FHI Aims in home directory...

export FHI_AIMS_ROOT=${HOME}/fhi-aims.200112_2
aims_version="200112_2.scalapack.mpi"

export OMP_NUM_THREADS=1

cp ${FHI_AIMS_ROOT}/benchmarks/Ac-Lys-Ala19-H/control.in .
cp ${FHI_AIMS_ROOT}/benchmarks/Ac-Lys-Ala19-H/geometry.in .

srun ${FHI_AIMS_ROOT}/build-intel/aims.$aims_version.x < /dev/null
```

See the accompanying submission script `submit-intel.sh`. A `submit-gnu.sh`
example is also available.






