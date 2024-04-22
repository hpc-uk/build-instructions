Instructions for installing PyTorch 1.13.1 for use on the ARCHER2 GPU nodes
===========================================================================

These instructions show how to install PyTorch 1.13.1 for use on the ARCHER2 GPU nodes (HPE Cray EX, AMD EPYC 7534P, AMD Instinct MI210).

Horovod 0.28.1, a distributed deep learning training framework, is also installed - this package can be used for running PyTorch across multiple GPU nodes.

This can also be done by using the ROCm Collective Communications Library (RCCL) directly via the `torch.distributed` module,
as is the case with the [DeepCAM MLPerf benchmark](https://github.com/mlcommons/hpc/tree/main/deepcam). 


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/python/core
cd ${PRFX}

PYTORCH_PACKAGE_LABEL=torch
PYTORCH_LABEL=py${PYTORCH_PACKAGE_LABEL}
PYTORCH_VERSION=1.13.1
PYTORCH_ROOT=${PRFX}/${PYTORCH_LABEL}/${PYTORCH_VERSION}-gpu

ROCM_VERSION=5.2.3
ROCM_TAG=`echo rocm${ROCM_VERSION} | cut -d. -f1-2`

module -q load PrgEnv-gnu
module -q load craype-x86-milan
module -q load craype-accel-amd-gfx90a
module -q load cray-python/3.9.13.1
module -q load cray-hdf5-parallel/1.12.2.1
module -q load rocm/${ROCM_VERSION}

PYTHON_VER=`echo ${CRAY_PYTHON_LEVEL} | cut -d. -f1-2`
PYTHON_VER2=`echo "${PYTHON_VER//./}"`

PYTHON_DIR=${PYTORCH_ROOT}/python
PYTHON_BIN=${PYTHON_DIR}/${CRAY_PYTHON_LEVEL}/bin
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.


Create and setup the PyTorch virtual python environment
-------------------------------------------------------

```bash
mkdir -p ${PYTHON_BIN}

export PIP_CACHE_DIR=${PYTHON_DIR}/.cache/pip

export PYTHONUSERBASE=${PYTHON_DIR}/${CRAY_PYTHON_LEVEL}
export PATH=${PYTHONUSERBASE}/bin:${PATH}
export PYTHONPATH=${PYTHONUSERBASE}/lib/python${PYTHON_VER}/site-packages:${PYTHONPATH}

pip install --user --upgrade pip
```


Install mpi4py
--------------

```bash
mkdir -p ${PYTORCH_ROOT}/repos
cd ${PYTORCH_ROOT}/repos

MPI4PY_LABEL=mpi4py
MPI4PY_VERSION=3.1.5
MPI4PY_NAME=${MPI4PY_LABEL}-${MPI4PY_VERSION}

git clone https://github.com/${MPI4PY_LABEL}/${MPI4PY_LABEL}.git ${MPI4PY_NAME}
cd ${MPI4PY_NAME}
git checkout ${MPI4PY_VERSION}

CC=cc CXX=CC FC=ftn python setup.py build
python setup.py install --prefix=${PYTORCH_ROOT}/python/${CRAY_PYTHON_LEVEL}
python setup.py clean --all
```


Install supporting packages
---------------------------

```bash
cd ${PYTORCH_ROOT}

pip install --user wandb
pip install --user gym
pip install --user pyspark
pip install --user scikit-learn
pip install --user scikit-image
pip install --user opencv-python
pip install --user wheel
pip install --user tomli
pip install --user h5py
```


Install the PyTorch packages
----------------------------

```bash
mkdir -p ${PYTORCH_ROOT}/wheels
cd ${PYTORCH_ROOT}/wheels

WHL_SFFX=cp${PYTHON_VER2}-cp${PYTHON_VER2}-linux_x86_64

wget https://download.pytorch.org/whl/${ROCM_TAG}/torch-${PYTORCH_VERSION}%2B${ROCM_TAG}-${WHL_SFFX}.whl
wget https://download.pytorch.org/whl/${ROCM_TAG}/torchvision-0.14.1%2B${ROCM_TAG}-${WHL_SFFX}.whl
wget https://download.pytorch.org/whl/${ROCM_TAG}/torchaudio-0.13.1%2B${ROCM_TAG}-${WHL_SFFX}.whl
wget https://download.pytorch.org/whl/torchtext-0.14.1-${WHL_SFFX}.whl

pip install --user torch-${PYTORCH_VERSION}+${ROCM_TAG}-${WHL_SFFX}.whl
pip install --user torchvision-0.14.1+${ROCM_TAG}-${WHL_SFFX}.whl
pip install --user torchaudio-0.13.1+${ROCM_TAG}-${WHL_SFFX}.whl
pip install --user torchtext-0.14.1-${WHL_SFFX}.whl
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


Install Horovod
---------------

```bash
cd ${PYTORCH_ROOT}

module load cmake/3.21.3

CC=cc CXX=CC FC=ftn HOROVOD_CPU_OPERATIONS=MPI HOROVOD_WITH_MPI=1 HOROVOD_GPU_OPERATIONS=NCCL HOROVOD_ROCM_HOME=${CRAY_ROCM_DIR} HOROVOD_GPU=ROCM HOROVOD_WITH_TENSORFLOW=0 HOROVOD_WITH_PYTORCH=1 HOROVOD_WITH_MXNET=0 pip install --user --no-cache-dir --no-deps horovod[pytorch]==0.28.1
```

Now run `horovodrun --check-build` to confirm that Horovod has been installed correctly. That command should return something like the following output.

```bash
Horovod v0.28.1:

Available Frameworks:
    [ ] TensorFlow
    [X] PyTorch
    [ ] MXNet

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


Install APEX
------------

APEX is a tool for enabling mixed precision within PyTorch.

```bash
mkdir -p ${PYTORCH_ROOT}/repos
cd ${PYTORCH_ROOT}/repos

git clone https://github.com/ROCm/apex
cd apex

# if pip < 23.1
pip install --user -v --disable-pip-version-check --no-cache-dir --no-build-isolation --global-option="--cpp_ext" --global-option="--cuda_ext" ./
# else
pip install --user -v --disable-pip-version-check --no-cache-dir --no-build-isolation --config-settings "--build-option=--cpp_ext" --config-settings "--build-option=--cuda_ext" ./
```


Create `extend-venv-activate` script
------------------------------------

The PyTorch Python environment described here is encapsulated as an Lmod module file on ARCHER2.
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
CMDS="${CMDS}module -q load pytorch/1.13.1-gpu\n\n"
CMDS="${CMDS}CRAY_PYTHON_VER=\`echo \${CRAY_PYTHON_LEVEL} | cut -d'.' -f1-2\`\n"
CMDS="${CMDS}PYTHONUSERSITEPKGS=${1}/lib/python\${CRAY_PYTHON_VER}/site-packages\n"
CMDS="${CMDS}if [[ \${PYTHONPATH} != *\"\${PYTHONUSERSITEPKGS}\"* ]]; then\n"
CMDS="${CMDS}  export PYTHONPATH=\${PYTHONUSERSITEPKGS}\:\${PYTHONPATH}\n"
CMDS="${CMDS}fi\n\n"

sed -ri "s:${MARK}:${CMDS}:g" ${1}/bin/activate


# add extra deactivation commands
INDENT="        "
MARK="unset -f deactivate"
CMDS="${MARK}\n\n" 
CMDS="${CMDS}${INDENT}export PYTHONPATH=\`echo \${PYTHONPATH} | sed \"\s\:\${PYTHONUSERSITEPKGS}\\\\\:\:\:\g\"\`\n"
CMDS="${CMDS}${INDENT}module -q unload pytorch/1.13.1-gpu"

sed -ri "s:${MARK}:${CMDS}:g" ${1}/bin/activate
```

Lastly, remember to set read and execute permission for all users, i.e., `chmod a+rx ${PYTHON_BIN}/extend-venv-activate`.

See the link below for an example of how the `extend-venv-activate` script is called.

[https://docs.archer2.ac.uk/user-guide/python/#installing-your-own-python-packages-with-pip](https://docs.archer2.ac.uk/user-guide/python/#installing-your-own-python-packages-with-pip)
