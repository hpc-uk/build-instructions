Instructions for compiling NWChem 7.0.2 for Cirrus
================================================

These instructions are for compiling NWChem on Cirrus
 using the GCC 10.2.0 compilers, Intel MKL 19 library, and HPE MPT 2.25 MPI library.

 Download NWChem
 ---------------

 Remember to set PRFX to your working directory.
 ```bash
 PRFX=/work/...
 cd $PRFX

 wget https://github.com/nwchemgit/nwchem/releases/download/v7.0.2-release/nwchem-7.0.2-release.revision-b9985dfa-srconly.2020-10-12.tar.bz2
```

Unpack
----------------
```bash
tar -xvf nwchem-7.0.2-release.revision-b9985dfa-srconly.2020-10-12.tar.bz2
cd nwchem-7.0.2
```

Set-up the environment
----------------

```bash
module load gcc/10.2.0
module load intel-cmkl-19/19.0.0.117
module load mpt/2.25
```

```bash
export NWCHEM_TOP=$PRFX/nwchem-7.0.2
export NWCHEM_TARGET=LINUX64

export ARMCI_NETWORK=MPI-PR

export NWCHEM_MODULES=all
export USE_MPI=y

export BLASOPT="-L${MKLROOT}/lib/intel64 -Wl,--no-as-needed -lmkl_gf_ilp64 -lmkl_sequential -lmkl_core -lpthread -lm -ldl"
export LAPACK_LIB="$BLASOPT"

export USE_SCALAPACK=y
export SCALAPACK="-L${MKLROOT}/lib/intel64 -Wl,--no-as-needed -lmkl_scalapack_ilp64 -lmkl_gf_ilp64 -lmkl_sequential -lmkl_core -lmkl_blacs_sgimpt_ilp64 -lpthread -lm -ldl"

export USE_NOIO=TRUE
```

``` bash
cd $NWCHEM_TOP/src
make nwchem_config
```

Edit lines 1269 and 1874 in config/makefile.h to remove ```-i8``` and replace with ```-fallow-argument-mismatch```.

```bash
make -j16 2>&1 | tee make.log
```

The binary is can be found at: `$NWCHEM_TOP/bin/LINUX64/nwchem`
