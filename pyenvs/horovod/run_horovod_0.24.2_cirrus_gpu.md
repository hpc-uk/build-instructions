Instructions for running Horovod on Cirrus (GPU)
================================================

These instructions are for running Horovod on the Cirrus GPU nodes (Cascade Lake, NVIDIA Tesla V100-SXM2-16GB).

Horovod 0.24.2 is made available by loading the `horovod/0.24.2-gpu` module; this starts a Miniconda3 environment
containing Horovod 0.24.2 and mpi4py 3.1.3 (built against Open MPI 4.1.2 and CUDA 11.6). Also included are
TensorFlow 2.8.0 and PyTorch 1.11.0.

Horovod is a key component as it allows the TensorFlow/PyTorch work to be distributed over CPUs and/or GPUs,
see [https://horovod.readthedocs.io/en/stable/mpi_include.html](https://horovod.readthedocs.io/en/stable/mpi_include.html).

For clarity, two module aliases are also provided, `tensorflow/2.8.0-gpu` and `pytorch/1.11.0`. Those two modules
are aliases for the `horovod/0.24.2-gpu` module.

The submission scripts below show how to run TensorFlow/PyTorch over multiple GPU nodes.
The jobs run benchmark scripts located within `/home/z04/shared/ml`.


Launch a TensorFlow MNIST benchmark
-----------------------------------

The script below launches a TensorFlow job that uses 16 GPUs across 4 Cascade Lake GPU nodes.


```bash
#!/bin/bash

#SBATCH --job-name=hvtf
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

# tensorflow module is an alias for horovod/0.24.2-gpu
module load tensorflow/2.8.0-gpu

scontrol show hostnames > ${SLURM_SUBMIT_DIR}/hosts

WORK_ROOT=${HOME/home/work}
DATA_ROOT=${WORK_ROOT}/.keras/datasets
rm -rf ${DATA_ROOT}
mkdir ${DATA_ROOT}

SHARED_ROOT=/work/z04/shared/ml/tensorflow/mnist
for tk in $(seq ${SLURM_NTASKS}); do
  rk=`expr ${tk} - 1`
  cp ${SHARED_ROOT}/data/mnist.npz ${DATA_ROOT}/mnist-${rk}.npz
done

mpirun -n ${SLURM_NTASKS} -N ${SLURM_NTASKS_PER_NODE} \
    -hostfile ${SLURM_SUBMIT_DIR}/hosts -bind-to none -map-by slot \
    -x HOROVOD_MPI=1 -x HOROVOD_MPI_THREADS_DISABLE=1 \
    -x NCCL_DEBUG=INFO -x LD_LIBRARY_PATH -x PATH \
    python ${SHARED_ROOT}/tensorflow_mnist.py

rm -f ${SLURM_SUBMIT_DIR}/hosts

CHECKPOINT_ROOT=${SLURM_SUBMIT_DIR}/checkpoints-${SLURM_JOBID}
mkdir ${CHECKPOINT_ROOT}
mv checkpoint ${CHECKPOINT_ROOT}/
mv checkpoints-*.data* ${CHECKPOINT_ROOT}/
mv checkpoints-*.index* ${CHECKPOINT_ROOT}/
```

If you wish to increase the number of GPUs to 32 for example, you will need to make
two changes to the script above.

```bash
...
#SBATCH --nodes=8
...
export SLURM_NTASKS=32
...
```

And if you wish to adjust the number of GPUs per node you will need to change
the `#SBATCH --gres=gpu:4` directive also.


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

# pytorch module is an alias for horovod/0.24.2-gpu
module load pytorch/1.11.0-gpu

scontrol show hostnames > ${SLURM_SUBMIT_DIR}/hosts

SHARED_ROOT=/work/z04/shared/ml/pytorch/mnist

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
