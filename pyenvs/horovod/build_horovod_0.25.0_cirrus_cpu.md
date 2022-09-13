Instructions for building Horovod for the Cirrus GPU nodes
==========================================================

These instructions show how to build a Python virtual environment (venv) that provides Horovod 0.25.0, a distributed deep learning training framework,
one that encompasses three ML libraries, [TensorFlow](https://www.tensorflow.org/), [PyTorch](https://pytorch.org/) and [MXNet](https://mxnet.apache.org/).
The instructions will attempt to install the latest versions of those libraries; as of 12 Sep 2022, these are TensorFlow 2.10.0, PyTorch 1.12.1 and MXNet 1.9.1.

The Horovod environment is intended to run on the Cirrus CPU nodes (Intel Xeon E5-2695, Broadwell).

This venv is an extension of the Miniconda3 (Python 3.9.13) environment provided by the `python/3.9.13` module.
MPI comms is handled by the [Horovod](https://horovod.readthedocs.io/en/stable/index.html) 0.25.0 package.
Horovod is required for running TensorFlow/PyTorch over multiple compute nodes.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/mnt/lustre/indy2lfs/sw
cd ${PRFX}

HOROVOD_LABEL=horovod
HOROVOD_VERSION=0.25.0
HOROVOD_ROOT=${PRFX}/${HOROVOD_LABEL}

module load python/3.9.13

PYTHON_VER=`echo ${MINICONDA3_PYTHON_VERSION} | cut -d'.' -f1-2`
PYTHON_DIR=${PRFX}/${HOROVOD_LABEL}/${HOROVOD_VERSION}/python
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

pip install --user tensorflow
pip install --user tensorflow-cpu
pip install --user tensorboard_plugin_profile

pip install --user torch
pip install --user torchvision
pip install --user pytorch-lightning
pip install --user pytorch-lightning-bolts
pip install --user pytorch-lightning-bolts["extra"]
pip install --user lightning-flash
pip install --user 'lightning-flash[all]'

pip install --user mxnet

pip install --user fastai
pip install --user opencv-python
```


Install Horovod
---------------

```bash
module load cmake

# switch from nvidia to openmpi compilers
CC_SAVE=${CC}
CXX_SAVE=${CXX}
FC_SAVE=${FC}
export CC=mpicc
export CXX=mpicxx
export FC=mpifort

HOROVOD_CPU_OPERATIONS=MPI HOROVOD_WITH_MPI=1 HOROVOD_WITH_TENSORFLOW=1 HOROVOD_WITH_PYTORCH=1 HOROVOD_WITH_MXNET=1 pip install --user --no-cache-dir horovod[tensorflow,pytorch,mxnet]==${HOROVOD_VERSION}

export CC=${CC_SAVE}
export CXX=${CXX_SAVE}
export FC=${FC_SAVE}
```

Now run `horovodrun --check-build` to confirm that [Horovod](https://horovod.readthedocs.io/en/stable/index.html) has been installed
correctly. That command should return something like the following output

```
Horovod v0.25.0:

Available Frameworks:
    [X] TensorFlow
    [X] PyTorch
    [X] MXNet

Available Controllers:
    [X] MPI
    [X] Gloo

Available Tensor Operations:
    [ ] NCCL
    [ ] DDL
    [ ] CCL
    [X] MPI
    [X] Gloo 
```
