Instructions for running PyTorch on Cirrus
==========================================

These instructions are for running PyTorch within a Miniconda3 environment on Cirrus
(SGI ICE XA, Intel Xeon Broadwell (CPU) and Cascade Lake (GPU)) using Python 3.8.

PyTorch 1.9.0 is made available by loading the `miniconda3/4.9.2-py38-torch` module; this starts a Miniconda3 environment
containing Horovod 0.22.1 and mpi4py 3.0.3 (built against Open MPI 4.1.0 and CUDA 11.2).

Horovod is a key component as it allows the PyTorch work to be distributed over CPUs and/or GPUs,
see [https://horovod.readthedocs.io/en/stable/mpi_include.html](https://horovod.readthedocs.io/en/stable/mpi_include.html).

The submission script below shows how to run PyTorch over multiple GPUs.
The job runs an MNIST benchmark using the scripts and data located within `/lustre/home/shared/ml/pytorch/benchmarks`.
Furthermore, PyTorch itself is encapsulated within the Pytorch Lightning framework (v1.3.8) as shown by
the contents of the `hvpytl.py` script.


Launch a PyTorch job that uses 2 GPUs on one Cascade Lake GPU node
------------------------------------------------------------------

```bash
#!/bin/bash

#SBATCH --job-name=hvpytlbm
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

rm -f ${SLURM_SUBMIT_DIR}/hosts
scontrol show hostnames > ${SLURM_SUBMIT_DIR}/hosts
HOST_LST=""
while read hn; do
  HOST_LST="${HOST_LST}${hn}:${SLURM_NTASKS_PER_NODE},"
done < ${SLURM_SUBMIT_DIR}/hosts
HOST_LST=${HOST_LST::-1}


module load miniconda3/4.9.2-py38-torch

BENCHMARKS_PATH=/lustre/home/shared/ml/pytorch/benchmarks
if [ ! -d "${SLURM_SUBMIT_DIR}/MNIST" ]; then
  cp -r ${BENCHMARKS_PATH}/MNIST ${SLURM_SUBMIT_DIR}/
fi

export OMPI_MCA_mca_base_component_show_load_errors=0

mpirun -n ${SLURM_NTASKS} -N ${SLURM_NTASKS_PER_NODE} \
    -host ${HOST_LST} -bind-to none -map-by slot \
    -x NCCL_DEBUG=INFO -x LD_LIBRARY_PATH -x HOROVOD_MPI_THREADS_DISABLE=1 -x PATH \
    --mca pml ob1 --mca mpi_warn_on_fork 0 \
    python ${BENCHMARKS_PATH}/hvpytl.py \
        --distributed_backend="horovod" \
        --max_epochs=100 --profiler="simple" \
        --batch_size=64 --num_workers=0


sed -i -e "s/\r/\n/g" slurm-${SLURM_JOB_ID}.out
sed -i -e "s/[\x01-\x1F\x7F]//g" slurm-${SLURM_JOB_ID}.out
sed -i -e "s/[\x5B\x41]//g" slurm-${SLURM_JOB_ID}.out
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