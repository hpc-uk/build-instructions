Instructions for building PyTorch 2.2.0 for the Cirrus GPU nodes
================================================================

These instructions show how to build a Python virtual environment (venv) that provides PyTorch 2.2.0 (https://pytorch.org/).
Also included is Horovod 0.28.1, a distributed deep learning training framework,

The PyTorchd environment is intended to run on the Cirrus GPU nodes (Cascade Lake, NVIDIA Tesla V100-SXM2-16GB).

This venv is an extension of the Miniconda3 (Python 3.11.5) environment provided by the `python/3.11.5-gpu` module.
MPI comms is handled by the [Horovod](https://horovod.readthedocs.io/en/stable/index.html) 0.28.1 package (built with NCCL 2.13.4).
Horovod is required for running PyTorch over multiple GPUs distributed across multiple compute nodes.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/mnt/lustre/indy2lfs/sw
cd ${PRFX}

PYTORCH_PACKAGE_LABEL=torch
PYTORCH_LABEL=py${PYTORCH_PACKAGE_LABEL}
PYTORCH_VERSION=2.2.0
PYTORCH_ROOT=${PRFX}/${PYTORCH_LABEL}

module use /work/y07/shared/cirrus-modulefiles-development
module load python/3.11.5-gpu

PYTHON_VER=`echo ${MINICONDA3_PYTHON_VERSION} | cut -d'.' -f1-2`
PYTHON_DIR=${PRFX}/${PYTORCH_LABEL}/${PYTORCH_VERSION}-gpu/python
PYTHON_BIN=${PYTHON_DIR}/${MINICONDA3_PYTHON_VERSION}/bin

mkdir -p ${PYTHON_BIN}

export PIP_CACHE_DIR=${PYTHON_DIR}/.cache/pip

export PYTHONUSERBASE=${PYTHON_DIR}/${MINICONDA3_PYTHON_VERSION}
export PATH=${PYTHONUSERBASE}/bin:${PATH}
export PYTHONPATH=${PYTHONUSERBASE}/lib/python${PYTHON_VER}/site-packages:${PYTHONPATH}
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Install torch and tensorboard packages
--------------------------------------

```bash
pip install --user torch==${PYTORCH_VERSION}+cu118 --extra-index-url https://download.pytorch.org/whl/cu118
pip install --user torchaudio==2.2.0+cu118 --extra-index-url https://download.pytorch.org/whl/cu118
pip install --user torchvision==0.17.0+cu118 --extra-index-url https://download.pytorch.org/whl/cu118
pip install --user torchtext==0.17.0 --extra-index-url https://download.pytorch.org/whl/cu118

pip install --user tensorboard
pip install --user tensorboard-pytorch
pip install --user tensorboard_plugin_profile
```


Install Horovod linking with the Nvidia Collective Communications Library (NCCL)
--------------------------------------------------------------------------------

Please note, in preparation for the Horovod install, you must check that `libcuda.so.1`
exists as soft link to `libcuda.so` in `${NVHPC_ROOT}/cuda/lib64/stubs`.

```bash
module load cmake

export LD_LIBRARY_PATH=${NVHPC_ROOT}/cuda/lib64/stubs:${LD_LIBRARY_PATH}

CC=mpicc CXX=mpicxx FC=mpifort HOROVOD_CUDA_HOME=${NVHPC_ROOT}/cuda/11.8 HOROVOD_NCCL_HOME=${NVHPC_ROOT}/comm_libs/nccl HOROVOD_GPU=CUDA HOROVOD_BUILD_CUDA_CC_LIST=70 HOROVOD_CPU_OPERATIONS=MPI HOROVOD_GPU_OPERATIONS=NCCL HOROVOD_WITH_MPI=1 HOROVOD_WITH_TENSORFLOW=0 HOROVOD_WITH_PYTORCH=1 HOROVOD_WITH_MXNET=0 CUDA_PATH=${NVHPC_ROOT}/cuda/11.8 pip install --user --no-cache-dir horovod[pytorch]==0.28.1


/mnt/lustre/indy2lfs/sw/pytorch/2.2.0-gpu/python/3.11.5/lib/python3.11/site-packages/torch/include/ATen/ATen.h:4:2: error: #error C++17 or later compatible compiler is required to use ATen.
Need somehow to get "-std=c++17" in the C++ compile options
"-std=c++14" is being specified instead
```

Now run `horovodrun --check-build` to confirm that [Horovod](https://horovod.readthedocs.io/en/stable/index.html) has been installed
correctly. That command should return something like the following output

```
Horovod v0.28.1:

Available Frameworks:
    [ ] TensorFlow
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
