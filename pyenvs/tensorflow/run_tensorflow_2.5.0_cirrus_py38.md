Instructions for running TensorFlow on Cirrus
=============================================

These instructions are for running TensorFlow within a Miniconda3 environment on Cirrus
(SGI ICE XA, Intel Xeon Broadwell (CPU) and Cascade Lake (GPU)) using Python 3.8.

TensorFlow 2.5.0 is made available by loading the `miniconda3/4.9.2-py38-tensorflow` module; this starts a Miniconda3 environment
containing Horovod 0.22.1 and mpi4py 3.0.3 (built against Open MPI 4.1.0 and CUDA 11.2).

Horovod is a key component as it allows the TensorFlow work to be distributed over CPUs and/or GPUs,
see [https://horovod.readthedocs.io/en/stable/mpi_include.html](https://horovod.readthedocs.io/en/stable/mpi_include.html).

The submission script below shows how to run TensorFlow over multiple GPU nodes.
The job runs a CNN benchmark script located within `/lustre/home/shared/ml/tensorflow/benchmarks` and
executes over 4 Cascade Lake GPU nodes using 4 GPUs per node (hence, there are 4 MPI ranks per node).


Launch a TensorFlow job that uses 16 GPUs across 4 Cascade Lake GPU nodes
-------------------------------------------------------------------------

```bash
#!/bin/bash

#SBATCH --job-name=hvtfbm
#SBATCH --time=00:20:00
#SBATCH --nodes=4
#SBATCH --exclusive
#SBATCH --partition=gpu-cascade
#SBATCH --qos=gpu
#SBATCH --gres=gpu:4
#SBATCH --account=[budget code]

export SLURM_NTASKS=16
export SLURM_NTASKS_PER_NODE=`expr ${SLURM_NTASKS} \/ ${SLURM_NNODES}`
export SLURM_TASKS_PER_NODE="${SLURM_NTASKS_PER_NODE}(x${SLURM_NNODES})"

module load miniconda3/4.9.2-py38-tensorflow

export OMPI_MCA_mca_base_component_show_load_errors=0

BENCHMARKS_PATH=/lustre/home/shared/ml/tensorflow/benchmarks/scripts/tf_cnn_benchmarks

rm -f ${SLURM_SUBMIT_DIR}/hosts
scontrol show hostnames > ${SLURM_SUBMIT_DIR}/hosts

mpirun -n ${SLURM_NTASKS} -N ${SLURM_NTASKS_PER_NODE} \
    -hostfile ${SLURM_SUBMIT_DIR}/hosts -bind-to none -map-by slot \
    -x HOROVOD_MPI=1 -x HOROVOD_MPI_THREADS_DISABLE=1 \
    -x NCCL_DEBUG=INFO -x LD_LIBRARY_PATH -x PATH \
    python ${BENCHMARKS_PATH}/tf_cnn_benchmarks.py \
        --data_format=NCHW --model=resnet50 --variable_update=horovod --num_gpus=1
```


If you wish to increase the number of GPUs to 32 for example, you will need to make
two changes to the script above.

```
...
#SBATCH --nodes=8
...
export SLURM_NTASKS=32
...
```

And if you wish to adjust the number of GPUs per node you will need to change
the `#SBATCH --gres=gpu:4` directive also.