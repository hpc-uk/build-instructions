# FHI-aims

FHI-aims (see, e.g., https://aimsclub.fhi-berlin.mpg.de) is usually compiled by individual users
who first must have obtained a license.

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

At the time of writing, compilation with `PrgEnv-cray` should be avoided. Continue
for one or both of `PrgEnv-intel` and `PrgEnv-gnu`.

## PrgEnv-intel (preferred)

```
tar xf fhi-aims.200112_2.tgz
cd fhi-aims.200112_2
export FHI_AIMS_ROOT=`pwd`

mkdir build-intel
cd build-intel

module swap PrgEnv-cray PrgEnv-intel
module swap intel intel/17.0.3.191
module swap gcc gc/6.3.0
module load cmake
module load cray-libsci

```

## PrgEnv-gnu (option)

At the time of writing we have as default `gcc/6.3.0` and `cmake/3.5.2`.

```
tar xf fhi-aims.200112_2.tgz
cd fhi-aims.200112_2
export FHI_AIMS_ROOT=`pwd`

mkdir build-gnu
cd build-gnu

module swap PrgEnv-cray PrgEnv-gnu
module load cmake

cat >> initial_cache.cmake << EOF
set(CMAKE_Fortran_COMPILER ftn CACHE STRING "")
set(CMAKE_Fortran_FLAGS "-O3 -ffree-line-length-none" CACHE STRING "")
set(Fortran_MIN_FLAGS "-O0 -ffree-line-length-none" CACHE STRING "")
set(CMAKE_C_COMPILER cc CACHE STRING "")
set(CMAKE_C_FLAGS "-O3" CACHE STRING "")
EOF

cmake -C intial_cache.cmake
make -j 6
```

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

Use the following submission script for a 48-core job. The account code
(PBS option `-A`) and `FHI_AIMS_ROOT` should be updated appropriately.
Note this is for `build-intel`.

```
#!/bin/bash

#PBS -l select=2
#PBS -l walltime=00:20:00
#PBS -j oe
#PBS -A z19-cse

# Directory from which PBS' qsub command was called.
cd $PBS_O_WORKDIR

# FHI-aims version variable to call the right binary (see below).

export FHI_AIMS_ROOT=/work/z01/z01/kevin/fhi-aims.200112_2
aims_version="200112_2.scalapack.mpi"

export OMP_NUM_THREADS=1

cp ${FHI_AIMS_ROOT}/benchmarks/Ac-Lys-Ala19-H/control.in .
cp ${FHI_AIMS_ROOT}/benchmarks/Ac-Lys-Ala19-H/geometry.in .

aprun -n 48 -N 24 ${FHI_AIMS_ROOT}/build-intel/aims.$aims_version.x < /dev/null
```

The script is available as a separate file.






