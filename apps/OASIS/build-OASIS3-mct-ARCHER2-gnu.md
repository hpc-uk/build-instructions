Instructions for compiling OASIS3-mct on ARCHER2
=======================================================

Set-up environment:
----------------------

```bash
PRFX=...
cd $PRFX

module swap PrgEnv-cray PrgEnv-gnu
module load cray-hdf5-parallel/1.12.0.3
module load cray-netcdf-hdf5parallel/4.7.4.3
```

Obtain the source code:
--------------------------
Source code can be obtained for free here: https://oasis.cerfacs.fr/en/download-oasis3-mct-sources/


Set-up Makefile:
--------------------

Place make.ARCHER2 (found in this directory) in $PRFX/oasis3-mct/util/make_dir and edit the make.inc to point to the location of the ARCHER2 make file:

```bash
include .../oasis3-mct/util/make_dir/make.ARCHER2
```
Be sure to write the absolute path and do not use environment variables like PRFX

When using make.ARCHER2, the path at line 12 will need to be updated.


Compiling for the SPOC_COMMUNICATION test case
------------------------------------------------

```bash
cd $PRFX/oasis3-mct/examples/spoc/spoc_communication

# Compile! Very quick...
make
```

Edit run_spoc to comment out the ```arch = # ```

```bash
./run_spoc
cd work_spoc_communication_4_4
```

Run with a heterogenous job script:
```bash
#!/bin/bash

#SBATCH --time=00:20:00
#SBATCH --exclusive
#SBATCH --export=none
#SBATCH --account=z19

#SBATCH --partition=standard
#SBATCH --qos=standard

# We must specify correctly the total number of nodes required.
#SBATCH --nodes=2

SHARED_ARGS="--distribution=block:block --hint=nomultithread"

module load cray-hdf5-parallel/1.12.0.3
module load cray-netcdf-hdf5parallel/4.7.4.3

srun --het-group=0 --nodes=1 --ntasks-per-node=4 ${SHARED_ARGS} ./ocean : \
 --het-group=1 --nodes=1 --ntasks-per-node=4 ${SHARED_ARGS} ./atmos
```
