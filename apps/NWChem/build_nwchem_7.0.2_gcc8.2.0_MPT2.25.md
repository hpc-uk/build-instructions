Instructions for compiling NWChem 7.0.2 on Cirrus
=================================================

These instructions are for building NWChem 7.2.0 on Cirrus CPU (SGI ICE XA, Intel Xeon Broadwell) using the GCC 8.2.0 compilers
and the HPE MPT MPI library.


Specify build location
----------------------
```bash
PRFX=/work/z04/shared/
cd $PRFX
```


Download and unpack NWChem
--------------------------

```bash
wget https://github.com/nwchemgit/nwchem/releases/download/v7.0.2-release/nwchem-7.0.2-release.revision-b9985dfa-srconly.2020-10-12.tar.bz2

tar -xvf nwchem-7.0.2-release.revision-b9985dfa-srconly.2020-10-12.tar.bz2
cd nwchem-7.0.2
```


Setup the environment
---------------------

Switch to the Gnu programming environment:

```bash
module load mpt/2.25
module load gcc/8.2.0
```

Set the build environment variables for NWChem:

```bash
export NWCHEM_TOP=$PRFX/nwchem-7.0.2
export NWCHEM_TARGET=LINUX64
export ARMCI_NETWORK=MPI-PR

export USE_MPI=y
export USE_MPIF=y
export USE_MPIF4=y

export NWCHEM_MODULES="all"  
export USE_NOIO=TRUE

export USE_INTERNALBLAS=y

export FC=gfortran  
export CC=gcc
```

Build
---------

```bash
cd $NWCHEM_TOP/src  

make nwchem_config
make
```

The binary is can be found at: `$NWCHEM_TOP/bin/LINUX64/nwchem`


Testing
===========

Test the NWChem installation using the simple test case, saved as 'n2.nw'

```bash
start h2o

title "H2O, cc-pVDZ basis, SCF optimized geometry"

geometry units au
H       0.0000000000   1.4140780900  -1.1031626600
H       0.0000000000  -1.4140780900  -1.1031626600
O       0.0000000000   0.0000000000  -0.0080100000
end

basis
H library cc-pVDZ
O library cc-pVDZ
end

scf
   thresh 1.0e-8
end

task scf

```

With submission script:

``` bash
#!/bin/bash

#SBATCH --job-name=NWChem_Example
#SBATCH --time=00:10:00

#SBATCH --nodes=1
#SBATCH --tasks-per-node=36
#SBATCH --cpus-per-task=1
#SBATCH --account=z04
#SBATCH --partition=standard
#SBATCH --qos=standard


module load mpt
module load gcc

srun /work/z04/shared/nwchem-7.0.2/bin/LINUX64/nwchem n2.nw
```
