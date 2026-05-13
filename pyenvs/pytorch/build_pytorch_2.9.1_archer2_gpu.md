Instructions for installing PyTorch 2.9.1 for use on the ARCHER2 GPU nodes
==========================================================================

These instructions show how to install PyTorch 2.9.1 for use on the ARCHER2 GPU nodes (HPE Cray EX, AMD EPYC 7534P, AMD Instinct MI210).

The ROCm Collective Communications Library (RCCL) can be used, via the `torch.distributed` module, to run PyTorch across multiple GPU nodes.

First, move to a folder appropriate for your ARCHER2 project, before shelling into a container, one that replicates the Python envionment present
on the GPU node.

```bash
cd /path/to/work  # e.g. /work/y07/shared/python/core/pytorch

module use /work/y07/shared/archer2-lmod/others/dev
module load ccpe/25.09-rocm-6.3.4

singularity shell --cleanenv --bind ${PWD} ${CCPE_IMAGE_FILE}
```

The above commands need to be run from an ARCHER2 login node in order for the pip install commands to work.

From within the container, we first source a script.


```bash
source /etc/bash.bashrc.local
```

This will generate an error, `The following module(s) are unknown: "xpmem" "libfabric"`, this can be ignored however.

Staying inside the container, simply run the following commands to install PyTorch 2.9.1 to a location on the login node.
Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.

```bash
module -q load craype-x86-milan
module -q load craype-accel-amd-gfx90a
module -q load rocm

module -q load PrgEnv-gnu

module -q load cray-python
module -q load cray-hdf5-parallel


PRFX=/path/to/work  # e.g. /work/y07/shared/python/core/pytorch

PYENV_LABEL=2.9.1-gpu
PYENV_ROOT=${PRFX}/${PYENV_LABEL}

ROCM_VERSION=${CRAY_ROCM_VERSION}
ROCM_TAG=`echo rocm${ROCM_VERSION} | cut -d. -f1-2`

PYTHON_VER=`echo ${CRAY_PYTHON_LEVEL} | cut -d. -f1-2`

PYTHON_DIR=${PYENV_ROOT}/python
PYTHON_BIN=${PYTHON_DIR}/${CRAY_PYTHON_LEVEL}/bin


mkdir -p ${PYTHON_BIN}

export PIP_CACHE_DIR=${PYTHON_DIR}/.cache/pip

export PYTHONUSERBASE=${PYTHON_DIR}/${CRAY_PYTHON_LEVEL}
export PATH=${PYTHONUSERBASE}/bin:${PATH}
export PYTHONPATH=${PYTHONUSERBASE}/lib/python${PYTHON_VER}/site-packages:${PYTHONPATH}


pip install --user --upgrade pip scipy

pip install --user torch==2.9.1 torchvision==0.24.1 torchaudio==2.9.1 --index-url https://download.pytorch.org/whl/rocm6.3

pip install --user torchtext==0.18.0 torchopt==0.7.3 matplotlib
```

Close the container by typing the `exit` command.


Create `extend-venv-activate` script
------------------------------------

The PyTorch Python environment described here is encapsulated as an Lmod module file on ARCHER2.
A user may build a local Python environment based on this module, `pytorch/2.9.1-gpu`, which
means that module must be loaded whenever the local environment is activated.

The `extend-venv-activate` script ensures that this happens: it modifies the local environment's
activate script such that the `pytorch/2.9.1-gpu` module is loaded during activation and unloaded
during deactivation.

The contents of the `extend-venv-activate` script are shown below. The file itself must be added
to the `${PYTHON_BIN}` directory.

```bash
#!/bin/bash

# add extra activate commands
MARK="# you cannot run it directly"
CMDS="${MARK}\n\n"
CMDS="${CMDS}module -q load pytorch/2.9.1-gpu\n\n"
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
CMDS="${CMDS}${INDENT}module -q unload pytorch/2.9.1-gpu"

sed -ri "s:${MARK}:${CMDS}:g" ${1}/bin/activate
```

Lastly, remember to set read and execute permission for all users, i.e., `chmod a+rx ${PYTHON_BIN}/extend-venv-activate`.

See the link below for an example of how the `extend-venv-activate` script is called.

[https://docs.archer2.ac.uk/user-guide/python/#installing-your-own-python-packages-with-pip](https://docs.archer2.ac.uk/user-guide/python/#installing-your-own-python-packages-with-pip)
