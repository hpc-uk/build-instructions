Instructions for building FDS 6.7.0 on ARCHER2
==============================================

These instructions are for building FDS 6.7.0 on the ARCHER2 full system (HPE Cray EX, AMD Zen2 7742) using GCC 10.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work

FDS_LABEL=fds
FDS_VERSION=6.7.0
FDS_NAME=${FDS_LABEL}-${FDS_VERSION}
FDS_TAG=${FDS_LABEL^^}${FDS_VERSION}
FDS_ROOT=${PRFX}/${FDS_LABEL}
FDS_BUILD_CFG=mpi_gnu_linux_64
FDS_BUILD=${FDS_ROOT}/${FDS_NAME}/Build/${FDS_BUILD_CFG}
FDS_INSTALL=${FDS_ROOT}/${FDS_VERSION}-ompi4-gcc10
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.


Download the FDS source
-----------------------

```bash
mkdir -p ${FDS_ROOT}
cd ${FDS_ROOT}

git clone https://github.com/firemodels/${FDS_LABEL}.git

mv ${FDS_LABEL} ${FDS_NAME}
cd ${FDS_NAME}

git checkout ${FDS_TAG}
```


Setup the module environment
----------------------------

```bash
module -q restore

module -q load PrgEnv-gnu
module -q swap gcc gcc/10.3.0

module -q load mkl/2023.0.0

module use /work/y07/shared/archer2-lmod/libs/dev/openmpi
module -q load openmpi/4.1.5-ofi-gcc10
```


Build FDS
---------

```bash
cd ${FDS_BUILD}

sed -i 's:.*FFLAGSMKL_OPENMPI = .*:& -I\${OPENMPI_DIR}/include -I\${OPENMPI_DIR}/lib:g' ../makefile
sed -i 's:.*LFLAGSMKL_OPENMPI = .*:& -L\${OPENMPI_DIR}/lib -lmpi -lmpi_mpifh:g' ../makefile

sed -i 's:.*FFLAGSMKL_GNU_OPENMPI = .*:& -I\${OPENMPI_DIR}/include -I\${OPENMPI_DIR}/lib:g' ../makefile
sed -i 's:.*LFLAGSMKL_GNU_OPENMPI = .*:& -L\${OPENMPI_DIR}/lib -lmpi -lmpi_mpifh:g' ../makefile

sed -i "s:${FDS_BUILD_CFG} \: FFLAGS = -m64:${FDS_BUILD_CFG} \: FFLAGS = -fallow-argument-mismatch -m64:g" ../makefile
sed -i "s:${FDS_BUILD_CFG} \: FCOMPL = mpifort:${FDS_BUILD_CFG} \: FCOMPL = ftn:g" ../makefile

./make_fds.sh

rm *.o *.mod
```


Install FDS
-----------

```bash
mkdir -p ${FDS_INSTALL}/bin

cp ${FDS_BUILD}/fds_${FDS_BUILD_CFG} ${FDS_INSTALL}/bin/fds
```


Run FDS
-------

To run FDS, submit the Slurm submission script below using the `sbatch` command.

```bash
#!/bin/bash

#SBATCH --job-name=fds
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=128
#SBATCH --cpus-per-task=1
#SBATCH --time=10:00:00
#SBATCH --account=<budget code> 
#SBATCH --partition=standard
#SBATCH --qos=standard


module -q restore

module -q load PrgEnv-gnu
module -q swap gcc gcc/10.3.0

module -q load mkl/2023.0.0

module use /work/y07/shared/archer2-lmod/libs/dev/openmpi
module -q load openmpi/4.1.5-ofi-gcc10


PRFX=</path/to/work>
FDS_LABEL=fds
FDS_VERSION=6.7.0
FDS_ROOT=${PRFX}/${FDS_LABEL}
FDS_EXE=${FDS_ROOT}/${FDS_VERSION}-ompi4-gcc10/bin/fds

export SRUN_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK
export OMP_NUM_THREADS=1


srun --cpu-freq=2250000 --distribution=block:block --hint=nomultithread \
    ${FDS_EXE} <input arguments> \
```
