Instructions for running Pynamic 1.3.3 on ARCHER2
=================================================

These instructions present two submission scripts for launching a Pynamic benchmark,
one that uses [Spindle](../spindle/README.md) and one that does not.

Please note, you must first build a Pynamic benchmark, see [./build_pynamic_1.3.3_archer2_gcc11.md](./build_pynamic_1.3.3_archer2_gcc11.md).


Setup initial environment
-------------------------

```bash
PRFX=${HOME/home/work}/tools

PYNAMIC_LABEL=pynamic
PYNAMIC_VERSION=1.3.3
PYNAMIC_NAME=${PYNAMIC_LABEL}-${PYNAMIC_VERSION}
PYNAMIC_ROOT=${PRFX}/${PYNAMIC_LABEL}

cd ${PYNAMIC_ROOT}/${PYNAMIC_NAME}/pynamic-pyMPI-2.6a1
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.


Launch a Pynamic benchmark
--------------------------

Create a Slurm submission script, `submit.ll`, as shown below and submit it using `sbatch`.

```slurm
#!/bin/bash --login

#SBATCH --job-name=pynamic
#SBATCH --nodes=128
#SBATCH --tasks-per-node=128
#SBATCH --cpus-per-task=1
#SBATCH --time=00:20:00
#SBATCH --account=<budget code>
#SBATCH --partition=standard
#SBATCH --qos=standard

module -q restore
module -q load PrgEnv-gnu
module -q load cray-python

export SRUN_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK}

export PATH=${PWD}:${PATH}
export LD_LIBRARY_PATH=${PWD}:${LD_LIBRARY_PATH}

srun --distribution=block:block --hint=nomultithread --unbuffered \
    pynamic-mpi4py `date +%s`
```


Launch a Pynamic benchmark with Spindle
---------------------------------------

Run same Pynamic benchmark, but this time the library loads and module imports
are handled by [Spindle](../spindle/README.md). Two options are critical here, `spindle --slurm` and
`srun --overlap`.

```slurm
#!/bin/bash --login

#SBATCH --job-name=pynamic
#SBATCH --nodes=128
#SBATCH --tasks-per-node=128
#SBATCH --cpus-per-task=1
#SBATCH --time=00:20:00
#SBATCH --account=<budget code>
#SBATCH --partition=standard
#SBATCH --qos=standard

module -q restore
module -q load PrgEnv-gnu
module -q load cray-python

module use /work/y07/shared/archer2-lmod/utils/dev
module -q load spindle

export SRUN_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK}

export PATH=${PWD}:${PATH}
export LD_LIBRARY_PATH=${PWD}:${LD_LIBRARY_PATH}

spindle --slurm \
    srun --overlap --distribution=block:block --hint=nomultithread --unbuffered \
        pynamic-mpi4py `date +%s`
```


Pynamic benchmark results
------------------------

Running the benchmark produces three timings that are written to the Slurm output file.

1. The time taken to import all modules &mdash; `module import time`.
2. The time taken to call a call a function from each module &mdash; `module visit time`.
3. The time taken to perform a fractal calculation involving an MPI Reduce, the so-called `fractal mpi time`

All times are given in seconds.
