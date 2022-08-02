Instructions for compiling Tcl-ChemShell 3.7.1 on ARCHER2 using GCC 10 compilers
================================================================================

These instructions are for compiling Tcl-ChemShell 3.7.1 on 
[ARCHER2](https://www.archer2.ac.uk) using the GCC 10 compilers.

Set up your environment
-----------------------

Go to your build directory and load the GNU programming environment:

```bash
  module load PrgEnv-gnu
  cd /work/.../<your_build_directory>
  export WORK_DIR=$(pwd)
```

Installing Tcl
--------------

```bash
  tar -xvf tcl8.6.8-src.tar.gz 
  cd tcl8.6.8/unix/
  export CC=cc
  ./configure --disable-threads --prefix=${WORK_DIR}/tcl8.6.8
  make
  make install
```

Installing NWChem
-----------------

```bash
  cd ${WORK_DIR}
  tar -xvf nwchem-7.0.2-release.revision-b9985dfa-srconly.2020-10-12.tar.bz2 
  cd nwchem-7.0.2/src
  
  export NWCHEM_TOP=${WORK_DIR}//nwchem-7.0.2
  export NWCHEM_TARGET=LINUX64
  export ARMCI_NETWORK=MPI-TS
  export USE_MPI=y
  export USE_MPIF=y
  export USER_MPIF4=y
  export LIBMPI=" "
  export BLASOPT=" "
  export USE_64TO32=y
  export HAS_BLAS=yes
  export USE_OPENMP=y
  export BLAS_SIZE=4
  export LAPACK_LIB=" "
  export LAPACK_SIZE=4
  export FC=ftn
  
  make -j16 FC=ftn nwchem_config NWCHEM_MODULES=all
  make -j16 64_to_32 | tee make.64to32.log
  make -j16 FC=ftn | tee make.log
```

Installing GULP
---------------

```bash
  cd ${WORK_DIR}
  tar -xvf gulp-6.0.tar.gz
  cd gulp-6.0/Src/
  ./mkgulp clean
  ./mkgulp -c cray -m -t lib
```

Installing Tcl-ChemShell
------------------------

```bash
  cd ${WORK_DIR}
  git clone --recurse-submodules https://gitlab.stfc.ac.uk/chemshell/chemsh-tcl.git
  cd chemsh-tcl/src/config
  git checkout -b 3.7.1
  
  export F77=ftn
  export F90=ftn
  export CC=cc
  export TCLROOT=${WORK_DIR}/tcl8.6.8
  export LIBTCL=${TCLROOT}/lib/libtcl8.6.so
  export TCLLIBPATH=${LIBTCL}
  export COMPILER_IS_GFORTRAN=1
  export CFLAGS="-fallow-argument-mismatch -fopenmp"
  export FFLAGS="-fallow-argument-mismatch -fopenmp"
  export F90FLAGS="-fallow-argument-mismatch -fopenmp"
  export LDFLAGS="-fopenmp"
  export MPIINC=-I/opt/cray/pe/mpich/8.1.4/ofi/gnu/9.1/include
  export NWCHEM_TOP=${WORK_DIR}/nwchem-7.0.2
  export NWCHEM_TARGET=LINUX64
  ./configure --with-mpi --with-ga=${NWCHEM_TOP}/src/tools/install \
              --with-nwchem --with-gulp=${WORK_DIR}/gulp-6.0
  cd ../
  make
```

The build will fail to compile index -- this requires an MPI job to run. We 
need to do this manually by running an interactive job session (make sure to 
change the budget code):

```bash
  srun --nodes=1 --tasks-per-node=1 --cpus-per-task=1 --account=<budget_code> \
                 --partition=standard --qos=short --pty /bin/bash
```

In this interactive session, run:

```bash
  export TCLLIBPATH=${WORK_DIR}/chemsh-tcl/tcl
  export LIBTCL=${WORK_DIR}/tcl8.6.8/lib/libtcl8.6.so
  export TCLLIB=${WORK_DIR}/tcl8.6.8/lib/libtcl8.6.so
  cd ../tcl
  srun --oversubscribe ../bin/chemsh.x index.chm | tee index.log
```

This should run and exit with code 0. Once this is done, exit the interactive 
session.

Testing Tcl-ChemShell
---------------------

Once the installation is complete, you can test whether your installation 
by running the `hybrid/shells_nwchem.chm`, `nwchem/butanol_shift.chm`, and 
`nwchem/butanol_shift.chm` examples to check that they produce the expected 
results. Create a slurm submission script that looks like this (make sure to 
change the budget code):

```bash
#!/bin/bash

#SBATCH --nodes=2
#SBATCH --partition=standard
#SBATCH --qos=short
#SBATCH --account=z19-guest
#SBATCH --time=0:5:0
#SBATCH --tasks-per-node=128
#SBATCH --cpus-per-task=1

module load PrgEnv-gnu
export WORK_DIR=/work/y07/shared/apps/core/tcl-chemshell/3.7.1
export LIBTCL=${WORK_DIR}/tcl8.6.8/lib/libtcl8.6.so
export TCLLIBPATH=${WORK_DIR}/chemsh-tcl/tcl
export PATH=${PATH}:${WORK_DIR}/chemsh-tcl/bin

export OMP_NUM_THREADS=1

srun --distribution=block:block --hint=nomultithread \
	chemsh.x ../examples/hybrid/shells_nwchem.chm | tee shells_nwchem.out
srun --distribution=block:block --hint=nomultithread \
        chemsh.x ../examples/nwchem/butanol_shift.chm | tee butanol_shift.out
srun --distribution=block:block --hint=nomultithread \
        chemsh.x ../examples/nwchem/butanol_shift_opt.chm | tee butanol_shift_opt.out
```

If everything works properly, each of these should exit with code 0. We've 
found that `nwchem/butanol_shift.chm` can exit with code 1, but that the 
values are within expected error.
