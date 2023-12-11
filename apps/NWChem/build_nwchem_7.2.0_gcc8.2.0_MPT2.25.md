Instructions for compiling NWChem 7.2.0 on Cirrus
=================================================

These instructions are for building NWChem 7.2.0 on Cirrus CPU (SGI ICE XA, Intel Xeon Broadwell) using the GCC 8.2.0 compilers
and the HPE MPT MPI library.


Specify initial environment
---------------------------

```bash
PRFX=/path/to/work # e.g., /mnt/lustre/indy2lfs/sw
NWCHEM_LABEL=openmpi
NWCHEM_VERSION=7.2.0
NWCHEM_NAME=${NWCHEM_LABEL}-${NWCHEM_VERSION}
NWCHEM_ROOT=${PRFX}/${NWCHEM_LABEL}

module load gcc/8.2.0
module load mpt/2.25
```


Clone source repo
-----------------

```bash
mkdir -p ${NWCHEM_ROOT}
cd ${NWCHEM_ROOT}

git clone https://github.com/nwchemgit/${NWCHEM_LABEL} ${NWCHEM_NAME}
cd ${NWCHEM_NAME}
git checkout v${NWCHEM_VERSION}-release
```


Specify build environment
-------------------------

```bash
export NWCHEM_TOP=${NWCHEM_ROOT}/${NWCHEM_NAME}
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
-----

```bash
cd ${NWCHEM_TOP}/src  
make nwchem_config
make
```

The binary is can be found at: `${NWCHEM_TOP}/bin/LINUX64/nwchem`



Testing
===========

Test the NWChem installation using the simple test case, saved as 'n2.nw'.

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

The necessary submission script is given below.

``` bash
#!/bin/bash

#SBATCH --job-name=nwchem
#SBATCH --time=00:10:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=36
#SBATCH --cpus-per-task=1
#SBATCH --account=<budget code>
#SBATCH --partition=standard
#SBATCH --qos=standard


module load mpt
module load gcc

srun /path/to/nwchem n2.nw
```
