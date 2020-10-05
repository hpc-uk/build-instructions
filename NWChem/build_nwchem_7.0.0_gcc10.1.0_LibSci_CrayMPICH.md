Instructions for compiling NWChem 7.0.0 on ARCHER2
==================================================

These instructions are for compiling NWChem on [ARCHER2](https://www.archer2.ac.uk)
(HPE Cray EX supercomputer, AMD 7742 64-core processors) using the GCC 10.1.0 compilers,
HPE Cray LibSci numerical libraries, and HPE Cray MPICH MPI library.

Download and unpack NWChem
--------------------------

```bash
wget https://github.com/nwchemgit/nwchem/releases/download/7.0.0-release/nwchem-7.0.0-release.revision-2c9a1c7c-srconly.2020-02-26.tar.bz2
tar -xvf nwchem-7.0.0-release.revision-2c9a1c7c-srconly.2020-02-26.tar.bz2
```

Setup the environment
---------------------

Switch to the Gnu programming environment:

```bash
module restore PrgEnv-gnu
```

Set the build environment variables for NWChem:

```bash
export NWCHEM_TOP=/work/z19/z19/aturner/software/NWChem/nwchem-7.0.0
export NWCHEM_TARGET=LINUX64  
export NWCHEM_MODULES=all  
export USE_MPI=y
export USE_MPIF=y
export USE_MPIF4=y
export USE_64TO32=y
export LIBMPI=" "
export BLASOPT=" "
export LAPACK_LIB=" "
```

**Note:** Using ScaLAPACK on ARCHER2 results in a binary that crashes with a
segfault and so should be avoided (i.e. **do not** set `USE_SCALAPAK=y` and 
`SCALAPACK=" "`).

Build NWChem
------------

Now, build NWChem with:

```bash
cd $NWCHM_TOP/src
make nwchem_config
make 64_to_32
make FC=ftn 2>&1 | tee make.log
```

The binary is can be found at: `$NWCHEM_TOP/bin/LINUX64/nwchem`




