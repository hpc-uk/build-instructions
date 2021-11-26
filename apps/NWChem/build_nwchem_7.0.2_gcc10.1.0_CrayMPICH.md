Instructions for compiling NWChem 7.0.2 on ARCHER2
==================================================

These instructions are for compiling NWChem on [ARCHER2](https://www.archer2.ac.uk)
(HPE Cray EX supercomputer, AMD 7742 64-core processors) using the GCC 10.1.0 compilers,
internal NWChem BLAS libraries, and HPE Cray MPICH MPI library.

Download and unpack NWChem
--------------------------

```bash
wget https://github.com/nwchemgit/nwchem/releases/download/v7.0.2-release/nwchem-7.0.2-release.revision-b9985dfa-srconly.2020-10-12.tar.bz2
```

Setup the environment
---------------------

Switch to the Gnu programming environment:

```bash
module load PrgEnv-gnu
```

Set the build environment variables for NWChem:

```bash
export NWCHEM_TOP=/work/y07/shared/nwchem/nwchem-7.0.2
export NWCHEM_TARGET=LINUX64
export NWCHEM_MODULES=all  
export USE_MPI=y
export USE_MPIF=y 
export USE_MPIF4=y 
export LIBMPI=" "
export USE_INTERNALBLAS=y
# export BLASOPT=" "
# export LAPACK_LIB=" "
export USE_NOIO=TRUE
```

**Note:** Using Cray LibSci on ARCHER2 results in a binary that crashes
and so should be avoided (i.e. **do not** set `BLASOPT=" "`, `LAPACK_LIB=" "`
, `USE_SCALAPAK=y` and `SCALAPACK=" "`).

Build NWChem
------------

Now, build NWChem with:

```bash
cd $NWCHM_TOP/src
make nwchem_config
make -j16 FC=ftn 2>&1 | tee make.log
```

The binary is can be found at: `$NWCHEM_TOP/bin/LINUX64/nwchem`




