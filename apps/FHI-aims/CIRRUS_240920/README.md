FHI-AIMS - September 20, 2024 
==================================

Instructions to build the September 2024 version of FHI-Aims on [CIRRUS](www.cirrus.ac.uk) using the Intel 20.4 compilers, IMPI and Scalapack. 

FHI-Aims requires a license to access the source code. Please see the documentation [here](https://fhi-aims.org/get-the-code-menu/get-the-code) to obtain the source code. 

On Cirrus, move to the /work filesystem: 
```bash 
PREFIX=/work/path/to/desired/install/location
cd $PREFIX
```

Transfer the source code to `$PREFIX` and unpack: 
```bash 
tar -xvf fhi-aims.240920.tgz 
cd fhi-aims.240920 
mkdir build-intel 
cd build-intel 
```

Set-up your environment env: 
```bash 
export FHI_AIMS_ROOT=`pwd`
module load intel-20.4/compilers
module load intel-20.4/mpi
module load intel-20.4/fc
module load intel-20.4/cmkl
module load cmake 
```

Small fix to one of the dependancies: 
```bash 
sed -i 's/error stop error%message/error stop/g' ../external_libraries/toml-f/src/tomlf/ser.f90
```

Set-up a file of cmake options: 
```bash 
cat >> initial_cache.cmake <<EOF
 set(CMAKE_Fortran_COMPILER mpiifort CACHE STRING "")
set(CMAKE_Fortran_FLAGS "-O3 -ip -fp-model precise" CACHE STRING "")
set(Fortran_MIN_FLAGS "-O0 -ip -fp-model precise" CACHE STRING "")
set(CMAKE_C_COMPILER mpiicc CACHE STRING "")
set(CMAKE_CXX_COMPILER mpiicpc CACHE STRING "")
set(CMAKE_C_FLAGS "-O3 -ip -fp-model precise" CACHE STRING "")
set(USE_SCALAPACK true CACHE BOOL "Use SCALAPACK")
set(CMAKE_EXE_LINKER_FLAGS "-L${MKLROOT}/lib/intel64 -lmkl_scalapack_lp64 -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lmkl_blacs_intelmpi_lp64 -lpthread -lm -ldl" CACHE STRING "")
EOF
```

Build: 
```bash 
cmake -C initial_cache.cmake ..
make -j 8 
```

Test: 
```bash 
#!/bin/bash --login

#SBATCH --exclusive
#SBATCH --nodes=2
#SBATCH --tasks-per-node=36
#SBATCH --cpus-per-task=1

#SBATCH --time=00:20:00

#SBATCH --account=z04
#SBATCH --partition=standard
#SBATCH --qos=standard

module load intel-20.4/compilers
module load intel-20.4/mpi
module load intel-20.4/fc
module load intel-20.4/cmkl

# Assume we have installed FHI Aims in home directory...

PREFIX=/work/z04/z04/ebroadwa/queries/
export FHI_AIMS_ROOT=${PREFIX}/fhi-aims.240920 
aims_version="240920.scalapack.mpi"

export OMP_NUM_THREADS=1

cp ${FHI_AIMS_ROOT}/benchmarks/Ac-Lys-Ala19-H/control.in .
cp ${FHI_AIMS_ROOT}/benchmarks/Ac-Lys-Ala19-H/geometry.in .

srun ${FHI_AIMS_ROOT}/build-intel/aims.$aims_version.x < /dev/null

```