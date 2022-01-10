Instructions for building a TensorFlow environment suitable for the Cirrus GPU nodes
====================================================================================

These instructions show how to build a Python virtual environment (venv) that provides tensorflow 2.7.0 and tensorflow-gpu 2.7.0,
see https://www.tensorflow.org/ for further details. The TensorFlow environment is intended to run on the Cirrus GPU nodes (Cascade Lake, NVIDIA Tesla V100-SXM2-16GB).

The venv is an extension of the Miniconda3 (Python 3.8.12) environment provided by the `mpi4py/3.1.3-ompi-gpu` module.
MPI comms is handled by the [Horovod](https://horovod.readthedocs.io/en/stable/index.html) 0.23.0 package (built with NCCL 2.8.3).
Horovod is required for running PyTorch over multiple GPUs distributed across multiple compute nodes.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/lustre/sw/miniconda3
cd ${PRFX}

TENSORFLOW_LABEL=tensorflow
TENSORFLOW_VERSION=2.7.0
TENSORFLOW_ROOT=${PRFX}/${TENSORFLOW_LABEL}

module use /lustre/sw/modulefiles.miniconda3
module load mpi4py/3.1.3-ompi-gpu

PYTHON_VER=`echo ${MINICONDA3_PYTHON_VERSION} | cut -d'.' -f1-2`
PYTHON_DIR=${PRFX}/${TENSORFLOW_LABEL}/${TENSORFLOW_VERSION}-gpu/python
PYTHON_BIN=${PYTHON_DIR}/${MINICONDA3_PYTHON_VERSION}/bin


mkdir -p ${PYTHON_BIN}

export PIP_CACHE_DIR=${PYTHON_DIR}/.cache/pip

export PYTHONUSERBASE=${PYTHON_DIR}/${MINICONDA3_PYTHON_VERSION}
export PATH=${PYTHONUSERBASE}/bin:${PATH}
export PYTHONPATH=${PYTHONUSERBASE}/lib/python${PYTHON_VER}/site-packages:${PYTHONPATH}
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Install the machine learning packages
-------------------------------------

```bash
pip install --user pyspark
pip install --user scikit-learn
pip install --user scikit-image

pip install --user ${TENSORFLOW_LABEL}==${TENSORFLOW_VERSION}
pip install --user ${TENSORFLOW_LABEL}-gpu==${TENSORFLOW_VERSION}
```


Install Horovod linking with the Nvidia Collective Communications Library (NCCL)
--------------------------------------------------------------------------------

```bash
CUDA_VERSION=11.2
NVIDIA_HPCSDK_ROOT=/lustre/sw/nvidia/hpcsdk-212/Linux_x86_64/21.2
CUDA_ROOT=${NVIDIA_HPCSDK_ROOT}/cuda/${CUDA_VERSION}
NCCL_ROOT=${NVIDIA_HPCSDK_ROOT}/comm_libs/${CUDA_VERSION}/nccl
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${NCCL_ROOT}/lib

module load cmake

HOROVOD_CUDA_HOME=${CUDA_ROOT} HOROVOD_NCCL_HOME=${NCCL_ROOT} \
HOROVOD_GPU=CUDA HOROVOD_BUILD_CUDA_CC_LIST=70 \
HOROVOD_CPU_OPERATIONS=MPI HOROVOD_GPU_OPERATIONS=NCCL \
HOROVOD_WITH_MPI=1 HOROVOD_WITH_TENSORFLOW=1 \
HOROVOD_WITH_PYTORCH=0 HOROVOD_WITH_MXNET=0 \
    pip install --no-cache-dir horovod[tensorflow]
```

Now run `horovodrun --check-build` to confirm that [Horovod](https://horovod.readthedocs.io/en/stable/index.html) has been installed
correctly. That command should return something like the following output

```
Horovod v0.23.0:

Available Frameworks:
    [X] TensorFlow
    [X] PyTorch
    [ ] MXNet

Available Controllers:
    [X] MPI
    [X] Gloo

Available Tensor Operations:
    [X] NCCL
    [ ] DDL
    [ ] CCL
    [X] MPI
    [X] Gloo 
```

Note that PyTorch is marked as an available framework; this looks to be due to an error within `horovodrun` as none of the
PyTorch packages are present in the TensorFlow environment.