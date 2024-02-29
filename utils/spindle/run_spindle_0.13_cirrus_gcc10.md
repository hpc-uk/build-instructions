Instructions for running Spindle 0.13 on Cirrus
===============================================

These instructions present a basic submission script that shows how to launch a Python code
such that the library loads (and package imports) are handled by Spindle.

You must of first installed Spindle, see [./build_spindle_0.13_cirrus_gcc10.md](./build_spindle_0.13_cirrus_gcc10.md).


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
#SBATCH --qos=standard
#SBATCH --exclusive

source ${HOME/home/work}/tools/spindle/0.13/env.sh

module -s load python/3.9.13

spindle --slurm --python-prefix=/mnt/lustre/indy2lfs/sw/miniconda3/4.12.0-py39 \
    srun --overlap --distribution=block:block --hint=nomultithread --unbuffered \
        python ${SLURM_SUBMIT_DIR}/test.py
```
