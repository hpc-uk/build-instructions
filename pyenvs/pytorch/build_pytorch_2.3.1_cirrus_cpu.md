Instructions for installing PyTorch 2.3.1 for use on the Cirrus CPU nodes
==========================================================================

These instructions show how to build a Python virtual environment (venv) that provides PyTorch 2.3.1 (https://pytorch.org/).
Also included is Horovod 0.28.1, a distributed deep learning training framework.

The PyTorch environment is intended to run on the Cirrus CPU nodes (Intel Xeon E5-2695, Broadwell).

This venv is an extension of the Miniconda3 (Python 3.12.1) environment provided by the `python/3.12.1` module.
MPI comms is handled by the [Horovod](https://horovod.readthedocs.io/en/stable/index.html) 0.28.1 package.
Horovod is required for running PyTorch over multiple compute nodes.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/cirrus-software
cd ${PRFX}

PYTORCH_PACKAGE_LABEL=torch
PYTORCH_LABEL=py${PYTORCH_PACKAGE_LABEL}
PYTORCH_VERSION=2.3.1
PYTORCH_ROOT=${PRFX}/${PYTORCH_LABEL}
PYTORCH_DIR=${PYTORCH_ROOT}/${PYTORCH_VERSION}

module -s load python/3.12.1

PYTHON_VER=`echo ${MINICONDA3_PYTHON_VERSION} | cut -d'.' -f1-2`
PYTHON_DIR=${PYTORCH_DIR}/python
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
cd ${PYTORCH_DIR}

pip install --user torch==${PYTORCH_VERSION} --extra-index-url https://download.pytorch.org/whl/cpu
pip install --user torchaudio==2.3.1 --extra-index-url https://download.pytorch.org/whl/cpu
pip install --user torchmetrics==1.0.3 --extra-index-url https://download.pytorch.org/whl/cpu
pip install --user torchtext==0.18.0 --extra-index-url https://download.pytorch.org/whl/cpu
pip install --user torchvision==0.18.1 --extra-index-url https://download.pytorch.org/whl/cpu
```



Install tensorboard packages
----------------------------

```bash
cd ${PYTORCH_DIR}

pip install --user tensorboard
pip install --user tensorboard_plugin_profile
pip install --user tensorboard-plugin-wit
pip install --user tensorboard-pytorch
pip install --user torch-tb-profiler
```


Install Horovod
---------------

We need to use a special flavour of horovod 0.28.1 here, one that gets round the `You need C++17 to compile PyTorch` error.

```bash
cd ${PYTORCH_DIR}

module -s load cmake/3.25.2

CC=mpicc CXX=mpicxx FC=mpifort HOROVOD_CPU_OPERATIONS=MPI HOROVOD_WITH_MPI=1 HOROVOD_WITH_TENSORFLOW=0 HOROVOD_WITH_PYTORCH=1 HOROVOD_WITH_MXNET=0 pip install --user --no-cache-dir -v git+https://github.com/thomas-bouvier/horovod.git@compile-cpp17
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


Create `extend-venv-activate` script
------------------------------------

The PyTorch Python environment described here is encapsulated as a TCL module file on Cirrus.
A user may build a local Python environment based on this module, `pytorch/2.3.1`, which
means that module must be loaded whenever the local environment is activated.

The `extend-venv-activate` script ensures that this happens: it modifies the local environment's
activate script such that the `pytorch/2.3.1` module is loaded during activation and unloaded
during deactivation.

The contents of the `extend-venv-activate` script are shown below. The file itself must be added
to the `${PYTHON_BIN}` directory.

```bash
#!/bin/bash
  
# add extra activate commands
MARK="# You cannot run it directly"
CMDS="${MARK}\n\n"  
CMDS="${CMDS}module -s load pytorch/2.3.1\n\n"
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
CMDS="${CMDS}${INDENT}module -s unload pytorch/2.3.1"

sed -ri "s:${MARK}:${CMDS}:g" ${1}/bin/activate
```

Lastly, remember to set read and execute permission for all users, i.e., `chmod a+rx ${PYTHON_BIN}/extend-venv-activate`.

See the link below for an example of how the `extend-venv-activate` script is called.

[https://docs.cirrus.ac.uk/user-guide/python/#installing-your-own-python-packages-with-pip](https://docs.cirrus.ac.uk/user-guide/python/#installing-your-own-python-packages-with-pip)
