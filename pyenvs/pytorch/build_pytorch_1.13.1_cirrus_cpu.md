Instructions for building PyTorch 1.13.1 for the Cirrus CPU nodes
=================================================================

These instructions show how to build a Python virtual environment (venv) that provides PyTorch 1.13.1 (https://pytorch.org/).
Also included is Horovod 0.28.1, a distributed deep learning training framework,

The PyTorch environment is intended to run on the Cirrus CPU nodes (Intel Xeon E5-2695, Broadwell).

This venv is an extension of the Miniconda3 (Python 3.9.13) environment provided by the `python/3.9.13` module.
MPI comms is handled by the [Horovod](https://horovod.readthedocs.io/en/stable/index.html) 0.28.1 package.
Horovod is required for running PyTorch over multiple compute nodes.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/cirrus-software
cd ${PRFX}

PYTORCH_PACKAGE_LABEL=torch
PYTORCH_LABEL=py${PYTORCH_PACKAGE_LABEL}
PYTORCH_VERSION=1.13.1
PYTORCH_ROOT=${PRFX}/${PYTORCH_LABEL}

module load python/3.9.13

PYTHON_VER=`echo ${MINICONDA3_PYTHON_VERSION} | cut -d'.' -f1-2`
PYTHON_DIR=${PRFX}/${PYTORCH_LABEL}/${PYTORCH_VERSION}/python
PYTHON_BIN=${PYTHON_DIR}/${MINICONDA3_PYTHON_VERSION}/bin

mkdir -p ${PYTHON_BIN}

export PIP_CACHE_DIR=${PYTHON_DIR}/.cache/pip

export PYTHONUSERBASE=${PYTHON_DIR}/${MINICONDA3_PYTHON_VERSION}
export PATH=${PYTHONUSERBASE}/bin:${PATH}
export PYTHONPATH=${PYTHONUSERBASE}/lib/python${PYTHON_VER}/site-packages:${PYTHONPATH}

pip install --user --upgrade pip
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Install torch and tensorboard packages
--------------------------------------

```bash
pip install --user torch==${PYTORCH_VERSION} --extra-index-url https://download.pytorch.org/whl/cpu
pip install --user torchaudio==0.13.1 --extra-index-url https://download.pytorch.org/whl/cpu
pip install --user torchvision==0.14.1 --extra-index-url https://download.pytorch.org/whl/cpu
pip install --user torchtext==0.14.1 --extra-index-url https://download.pytorch.org/whl/cpu

pip install --user tensorboard
pip install --user tensorboard-pytorch
pip install --user tensorboard_plugin_profile
```


Install Horovod
---------------

```bash
module load cmake/3.25.2

CC=mpicc CXX=mpicxx FC=mpifort HOROVOD_CPU_OPERATIONS=MPI HOROVOD_WITH_MPI=1 HOROVOD_WITH_TENSORFLOW=0 HOROVOD_WITH_PYTORCH=1 HOROVOD_WITH_MXNET=0 pip install --user --no-cache-dir horovod[pytorch]==0.28.1
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
