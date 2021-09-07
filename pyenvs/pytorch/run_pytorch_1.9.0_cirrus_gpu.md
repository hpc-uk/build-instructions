Instructions for running PyTorch on Cirrus (GPU)
================================================

These instructions are for running PyTorch within a Miniconda3 environment on the Cirrus GPU nodes (Cascade Lake, NVIDIA Tesla V100-SXM2-16GB).

PyTorch 1.9.0 is made available by loading the `miniconda3/4.9.2-gpu-torch` module; this starts a Miniconda3 environment
containing Horovod 0.22.1 and mpi4py 3.0.3 (built against Open MPI 4.1.0 and CUDA 11.2).

Horovod is a key component as it allows the PyTorch work to be distributed over CPUs and/or GPUs,
see [https://horovod.readthedocs.io/en/stable/mpi_include.html](https://horovod.readthedocs.io/en/stable/mpi_include.html).

The submission script below shows how to run PyTorch over multiple GPUs.
The job runs an MNIST benchmark using the scripts and data located within `/lustre/home/shared/ml/pytorch/benchmarks/mnist`.


Launch a PyTorch job that uses 2 GPUs on one Cascade Lake GPU node
------------------------------------------------------------------

```bash
#!/bin/bash

#SBATCH --job-name=hvpt
#SBATCH --time=02:00:00
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --partition=gpu-cascade
#SBATCH --qos=gpu
#SBATCH --gres=gpu:2
#SBATCH --account=[budget code]

export SLURM_NTASKS=2
export SLURM_NTASKS_PER_NODE=`expr ${SLURM_NTASKS} \/ ${SLURM_NNODES}`
export SLURM_TASKS_PER_NODE="${SLURM_NTASKS_PER_NODE}(x${SLURM_NNODES})"

module load miniconda3/4.9.2-gpu-torch

scontrol show hostnames > ${SLURM_SUBMIT_DIR}/hosts

BENCHMARKS_PATH=/lustre/home/shared/ml/pytorch/benchmarks/synthetic

mpirun -n ${SLURM_NTASKS} -N ${SLURM_NTASKS_PER_NODE} \
    -hostfile ${SLURM_SUBMIT_DIR}/hosts -bind-to none -map-by slot \
    -x HOROVOD_MPI=1 -x HOROVOD_MPI_THREADS_DISABLE=1 \
    -x NCCL_DEBUG=INFO -x PYTHONWARNINGS="ignore::UserWarning" \
    -x LD_LIBRARY_PATH -x PATH \
    python ${BENCHMARKS_PATH}/pytorch_synthetic_benchmark.py
```


If you wish to increase the number of GPUs to 4 for example, you will need to make
two changes to the script above.

```
...
#SBATCH --gres=gpu:4
...
export SLURM_NTASKS=4
...
```

And if you wish to use more than one GPU node you will need to change
the `#SBATCH --nodes=1` directive also.