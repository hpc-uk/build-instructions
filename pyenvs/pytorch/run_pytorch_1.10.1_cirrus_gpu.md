Instructions for running PyTorch on Cirrus (GPU)
================================================

These instructions are for running PyTorch on the Cirrus GPU nodes (Cascade Lake, NVIDIA Tesla V100-SXM2-16GB).

PyTorch 1.10.1 is made available by loading the `pytorch/1.10.1-gpu` module; this starts a Miniconda3 environment
containing Horovod 0.23.0 and mpi4py 3.1.3 (built against Open MPI 4.1.0 and CUDA 11.2).

Horovod is a key component as it allows the PyTorch work to be distributed over CPUs and/or GPUs,
see [https://horovod.readthedocs.io/en/stable/mpi_include.html](https://horovod.readthedocs.io/en/stable/mpi_include.html).

The instructions below explain how to run PyTorch over multiple GPUs.


Launch a PyTorch MNIST benchmark
--------------------------------

The script below launches a PyTorch job that uses 2 GPUs on one Cascade Lake GPU node.


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

module use /lustre/sw/modulefiles.miniconda3
module load pytorch/1.10.1-gpu

scontrol show hostnames > ${SLURM_SUBMIT_DIR}/hosts

SHARED_ROOT=/lustre/home/shared/ml/pytorch/mnist

if [ ! -d ${SLURM_SUBMIT_DIR}/data ]; then
  cp -r ${SHARED_ROOT}/data ${SLURM_SUBMIT_DIR}/
fi

mpirun -n ${SLURM_NTASKS} -N ${SLURM_NTASKS_PER_NODE} \
    --mca mpi_warn_on_fork 0 \
    -hostfile ${SLURM_SUBMIT_DIR}/hosts -bind-to none -map-by slot \
    -x HOROVOD_MPI=1 -x HOROVOD_MPI_THREADS_DISABLE=1 \
    -x NCCL_DEBUG=INFO -x PYTHONWARNINGS="ignore::UserWarning" \
    -x LD_LIBRARY_PATH -x PATH \
    python ${SHARED_ROOT}/pytorch_mnist.py \
        --data-dir ${SLURM_SUBMIT_DIR}/data --batch-size 64 --epochs 10

rm -f hosts
```


If you wish to increase the number of GPUs to 4 for example, you will need to make
two changes to the script above.

```bash
...
#SBATCH --gres=gpu:4
...
export SLURM_NTASKS=4
...
```

And if you wish to use more than one GPU node you will need to change
the `#SBATCH --nodes=1` directive also.