Instructions for running Spindle 0.13 on ARCHER2
================================================

These instructions present a basic submission script that shows how to launch a Python code
such that the library loads (and package imports) are handled by Spindle.

You must of first installed Spindle, see [./build_spindle_.0.13_archer2.md](./build_spindle_0.13_archer2.md).


Create submission script
------------------------

Create a Slurm submission script, `submit.ll`, as shown below.

```bash
#!/bin/bash --login

#SBATCH --job-name=test
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:20:00
#SBATCH --account=<budget code>
#SBATCH --partition=standard
#SBATCH --qos=short


source ${HOME/home/work}/tools/spindle/0.13/env.sh

module load cray-python

export SRUN_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK}

spindle --slurm \
    srun --overlap --distribution=block:block --hint=nomultithread --unbuffered \
        python ${SLURM_SUBMIT_DIR}/test.py
```
