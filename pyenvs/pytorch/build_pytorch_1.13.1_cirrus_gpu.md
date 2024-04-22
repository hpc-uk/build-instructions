Instructions for installing PyTorch 1.13.1 for use on the Cirrus GPU nodes
==========================================================================

These instructions show how to build a Python virtual environment (venv) that provides PyTorch 1.13.1 (https://pytorch.org/).
Also included is Horovod 0.28.1, a distributed deep learning training framework.

The PyTorch environment is intended to run on the Cirrus GPU nodes (Cascade Lake, NVIDIA Tesla V100-SXM2-16GB).

This venv is an extension of the Miniconda3 (Python 3.10.8) environment provided by the `python/3.10.8-gpu` module.
MPI comms is handled by the [Horovod](https://horovod.readthedocs.io/en/stable/index.html) 0.28.1 package (built with NCCL 2.11.4).
Horovod can be used to run PyTorch across multiple GPU nodes.

This can also be done by using the NVIDIA Collective Communications Library (NCCL) directly via the `torch.distributed` module,
as is the case with the [DeepCAM MLPerf benchmark](https://github.com/mlcommons/hpc/tree/main/deepcam).


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/cirrus-software
cd ${PRFX}

PYTORCH_PACKAGE_LABEL=torch
PYTORCH_LABEL=py${PYTORCH_PACKAGE_LABEL}
PYTORCH_VERSION=1.13.1
PYTORCH_ROOT=${PRFX}/${PYTORCH_LABEL}/${PYTORCH_VERSION}-gpu

module -s load python/3.10.8-gpu

PYTHON_VER=`echo ${MINICONDA3_PYTHON_VERSION} | cut -d'.' -f1-2`
PYTHON_DIR=${PYTORCH_ROOT}/python
PYTHON_BIN=${PYTHON_DIR}/${MINICONDA3_PYTHON_VERSION}/bin

mkdir -p ${PYTHON_BIN}

export PIP_CACHE_DIR=${PYTHON_DIR}/.cache/pip

export PYTHONUSERBASE=${PYTHON_DIR}/${MINICONDA3_PYTHON_VERSION}
export PATH=${PYTHONUSERBASE}/bin:${PATH}
export PYTHONPATH=${PYTHONUSERBASE}/lib/python${PYTHON_VER}/site-packages:${PYTHONPATH}

pip install --user --upgrade pip
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Install torch packages
----------------------

```bash
cd ${PYTORCH_ROOT}

pip install --user torch==${PYTORCH_VERSION}+cu116 --extra-index-url https://download.pytorch.org/whl/cu116
pip install --user torchaudio==0.13.1+cu116 --extra-index-url https://download.pytorch.org/whl/cu116
pip install --user torchvision==0.14.1+cu116 --extra-index-url https://download.pytorch.org/whl/cu116
pip install --user torchtext==0.14.1 --extra-index-url https://download.pytorch.org/whl/cu116
pip install --user torchmetrics==1.0.3 --extra-index-url https://download.pytorch.org/whl/cu116
```


Install lightning packages
--------------------------

```bash
cd ${PYTORCH_ROOT}

pip install --user lightning==2.2.1
```


Install tensorboard packages
----------------------------

```bash
cd ${PYTORCH_ROOT}

pip install --user tensorboard==2.11.2
pip install --user tensorboard_plugin_profile==2.11.2
pip install --user tensorboard-plugin-wit
pip install --user tensorboard-pytorch
```


Install Horovod linking with the Nvidia Collective Communications Library (NCCL)
--------------------------------------------------------------------------------

Please note, in preparation for the Horovod install, you must check that `libcuda.so.1`
exists as soft link to `libcuda.so` in `${NVHPC_ROOT}/cuda/lib64/stubs`.

```bash
cd ${PYTORCH_ROOT}

module -s load cmake/3.25.2

export LD_LIBRARY_PATH=${NVHPC_ROOT}/cuda/lib64/stubs:${LD_LIBRARY_PATH}

CC=mpicc CXX=mpicxx FC=mpifort HOROVOD_CUDA_HOME=${NVHPC_ROOT}/cuda/11.6 HOROVOD_NCCL_HOME=${NVHPC_ROOT}/comm_libs/nccl HOROVOD_GPU=CUDA HOROVOD_BUILD_CUDA_CC_LIST=70 HOROVOD_CPU_OPERATIONS=MPI HOROVOD_GPU_OPERATIONS=NCCL HOROVOD_WITH_MPI=1 HOROVOD_WITH_TENSORFLOW=0 HOROVOD_WITH_PYTORCH=1 HOROVOD_WITH_MXNET=0 CUDA_PATH=${NVHPC_ROOT}/cuda/11.6 pip install --user --no-cache-dir horovod[pytorch]==0.28.1
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


Install APEX
------------

APEX is a tool for enabling mixed precision within PyTorch.

```bash
mkdir -p ${PYTORCH_ROOT}/repos
cd ${PYTORCH_ROOT}/repos

git clone https://github.com/NVIDIA/apex
cd apex

# if pip < 23.1
pip install --user -v --disable-pip-version-check --no-cache-dir --no-build-isolation --global-option="--cpp_ext" --global-option="--cuda_ext" ./
# else
pip install --user -v --disable-pip-version-check --no-cache-dir --no-build-isolation --config-settings "--build-option=--cpp_ext" --config-settings "--build-option=--cuda_ext" ./
```


Create `extend-venv-activate` script
------------------------------------

The PyTorch Python environment described here is encapsulated as a TCL module file on Cirrus.
A user may build a local Python environment based on this module, `pytorch/1.13.1-gpu`, which
means that module must be loaded whenever the local environment is activated.

The `extend-venv-activate` script ensures that this happens: it modifies the local environment's
activate script such that the `pytorch/1.13.1-gpu` module is loaded during activation and unloaded
during deactivation.

The contents of the `extend-venv-activate` script are shown below. The file itself must be added
to the `${PYTHON_BIN}` directory.

```bash
#!/bin/bash
  
# add extra activate commands
MARK="# you cannot run it directly"
CMDS="${MARK}\n\n"
CMDS="${CMDS}module -s load pytorch/1.13.1-gpu\n\n"
CMDS="${CMDS}PYTHONUSERSITEPKGS=${1}/lib/\${MINICONDA3_PYTHON_LABEL}/site-packages\n"
CMDS="${CMDS}if [[ \${PYTHONPATH} != *\"\${PYTHONUSERSITEPKGS}\"* ]]; then\n"
CMDS="${CMDS}  export PYTHONPATH=\${PYTHONUSERSITEPKGS}\:\${PYTHONPATH}\n"
CMDS="${CMDS}fi\n\n"

sed -ri "s:${MARK}:${CMDS}:g" ${1}/bin/activate


# add extra deactivation commands
INDENT="        "
MARK="unset -f deactivate"
CMDS="${MARK}\n\n"
CMDS="${CMDS}${INDENT}export PYTHONPATH=\`echo \${PYTHONPATH} | sed \"\s\:\${PYTHONUSERSITEPKGS}\\\\\:\:\:\g\"\`\n"
CMDS="${CMDS}${INDENT}module -s unload pytorch/1.13.1-gpu"

sed -ri "s:${MARK}:${CMDS}:g" ${1}/bin/activate
```

Lastly, remember to set read and execute permission for all users, i.e., `chmod a+rx ${PYTHON_BIN}/extend-venv-activate`.

See the link below for an example of how the `extend-venv-activate` script is called.

[https://docs.cirrus.ac.uk/user-guide/python/#installing-your-own-python-packages-with-pip](https://docs.cirrus.ac.uk/user-guide/python/#installing-your-own-python-packages-with-pip)
