Running NAMD 2.11 on ARCHER KNL
===============================

Instructions on how to run NAMD 2.11 on ARCHER KNL.

This document assumes you have built a copy of NAMD 2.11 according to the 
instructions at [NAMD 2.11 ARCHER KNL Build Instructions](build_namd_2.11_knl.md).

Modules and Environment Required
--------------------------------

In your job submission script you should load the following modules

```bash
module swap PrgEnv-cray PrgEnv-intel
module load rca
module load craype-hugepages8M
```

and set the following environment variables:

```bash
export HUGETLB_DEFAULT_PAGE_SIZE=8M
export HUGETLB_MORECORE=no
```

Specifying process/thread placement
-----------------------------------

When running NAMD on ARCHER KNL you will need to specify how to place the threads
and processes. You should always aim to use NAMD on KNL with both MPI processes
and OpenMP threads.

### Example: 16 threads per process ###

A good first place to start with benchmarking is to use 4 MPI processes per 
KNL node with 16 OpenMP threads per process. (Remember that a KNL node
has 64 physical nodes).

This would give 15 worker threads per MPI process and 1 control thread. To
use NAMD in this mode we also need to psecify the binding of the threads.

For example, to use 2 KNL nodes we would have 8 MPI processes (4 per node)
and 16 OpenMP threads per process and the launch line for such a setup would be:

```bash
aprun -n 8 -N 4 -d 16 -cc depth $NAMD_DIR/namd2 +ppn 15 +pemap 1-15,17-31,33-47,49-63 +commap 0,16,32,48 input.namd
```

The `aprun` options tell the Cray system how to distribute the processes and
threads and then the `namd2` options specify the binding.

The full KNL job submission script for such a setup would look like:

```bash
#!/bin/bash --login
#PBS -N namd_apoa1
#PBS -l select=2:aoe=quad_100
#PBS -l walltime=0:20:0
# Change this to your KNL budget
#PBS -A k01-user

module swap PrgEnv-cray PrgEnv-intel
module load rca
module load craype-hugepages8M
export HUGETLB_DEFAULT_PAGE_SIZE 8M
export HUGETLB_MORECORE no

# Move to directory that script was submitted from
export PBS_O_WORKDIR=$(readlink -f $PBS_O_WORKDIR)
cd $PBS_O_WORKDIR

export NAMD_DIR=/work/knl-users/aturner/NAMD/NAMD_2.11_Source/CRAY-XC-intel

# you should replace "input.namd" in the line below with your input filename
aprun -n 8 -N 4 -d 16 -cc depth $NAMD_DIR/namd2 +ppn 15 +pemap 1-15,17-31,33-47,49-63 +commap 0,16,32,48 input.namd
```
### Example: 64 threads per process ###

As the KNL nodes allow up to 4 hyperthreads per core, you can use a maximum of 256
processes/threads per node. For two nodes with 4 processes per node and 64 threads
per process we would use the following launch line:

```bash
aprun -n 8 -N 4 -d 64 -j 4 -cc depth $NAMD_DIR/namd2 +ppn 63 +pemap 1-63,65-127,129-191,193-255 +commap 0,64,128,192 input.namd
```

Note the addition of the `-j 4` option to `aprun` to specify 4 hyperthreads per core.

The rest of the job submission script would be identical to that above.
