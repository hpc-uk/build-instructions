Instructions for building a Miniconda3 environment suitable for Cirrus GPU nodes
================================================================================

These instructions show how to build Miniconda3 environment (based on Python 3.10.8) for the Cirrus GPU nodes
(Cascade Lake, NVIDIA Tesla V100-SXM2-16GB), one that supports parallel computation.

The environment features mpi4py 3.1.5 (OpenMPI 4.1.6 with ucx 1.15.0 and CUDA 11.6) with pycuda 2022.1
and cupy 10.6.0. It also provides a suite of packages pertinent to parallel processing and numerical analysis,
e.g., dask, ipyparallel, jupyter, matplotlib, numpy, pandas and scipy.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/cirrus-software
cd ${PRFX}

NVHPC_VERSION=22.2
CUDA_VERSION=11.6
OPENMPI_VERSION=4.1.6

module load nvidia/nvhpc-nompi/${NVHPC_VERSION}
module load openmpi/${OPENMPI_VERSION}-cuda-${CUDA_VERSION}

MPI4PY_LABEL=mpi4py
MPI4PY_VERSION=3.1.5

PYTHON_LABEL=py310
MINICONDA_TAG=miniconda
MINICONDA_LABEL=${MINICONDA_TAG}3
MINICONDA_VERSION=22.11.1-1
MINICONDA_ROOT=${PRFX}/${MINICONDA_LABEL}/${MINICONDA_VERSION}-${PYTHON_LABEL}-gpu
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Create and setup a Miniconda3 virtual environment
-------------------------------------------------

```bash
MINICONDA_TITLE=${MINICONDA_LABEL^}
MINICONDA_BASH_SCRIPT=${MINICONDA_TITLE}-${PYTHON_LABEL}_${MINICONDA_VERSION}-Linux-x86_64.sh

mkdir -p ${MINICONDA_LABEL}
cd ${MINICONDA_LABEL}

wget https://repo.anaconda.com/${MINICONDA_TAG}/${MINICONDA_BASH_SCRIPT}
chmod 700 ${MINICONDA_BASH_SCRIPT}
unset PYTHONPATH
bash ${MINICONDA_BASH_SCRIPT} -b -f -p ${MINICONDA_ROOT}
rm ${MINICONDA_BASH_SCRIPT}
cd ${MINICONDA_ROOT}

PATH=${MINICONDA_ROOT}/bin:${PATH}
conda init --dry-run --verbose > activate.sh
conda_env_start=`grep -n "# >>> conda initialize >>>" activate.sh | cut -d':' -f 1`
conda_env_stop=`grep -n "# <<< conda initialize <<<" activate.sh | cut -d':' -f 1`

echo "sed -n '${conda_env_start},${conda_env_stop}p' activate.sh > activate2.sh" > sed.sh
echo "sed 's/^.//' activate2.sh > activate.sh" >> sed.sh
echo "rm activate2.sh" >> sed.sh
. ./sed.sh
rm ./sed.sh

. ${MINICONDA_ROOT}/activate.sh

export PS1="(python-gpu) [\u@\h \W]\$ "
```


Build and install mpi4py using OpenMPI 4.1.6-cuda-11.6
------------------------------------------------------

```bash
cd ${MINICONDA_ROOT}

MPI4PY_NAME=${MPI4PY_LABEL}-${MPI4PY_VERSION}

mkdir -p ${MPI4PY_LABEL}
cd ${MPI4PY_LABEL}

git clone https://github.com/${MPI4PY_LABEL}/${MPI4PY_LABEL}.git ${MPI4PY_NAME}
cd ${MPI4PY_NAME}
git checkout ${MPI4PY_VERSION}

CC=mpicc CXX=mpicxx FC=mpifort python setup.py build
python setup.py install --prefix=${MINICONDA_ROOT}
python setup.py clean --all
```


Checking the mpi4py package
---------------------------

To show the MPI library supporting mpi4py, simply start a Python session and run the following commands.

```python
import mpi4py.rc
mpi4py.rc.initialize = False
from mpi4py import MPI
MPI.Get_library_version()
exit()
```


Download pycuda source
----------------------

```bash
cd ${MINICONDA_ROOT}

PYCUDA_LABEL=pycuda
PYCUDA_VERSION=2022.2.2
PYCUDA_NAME=${PYCUDA_LABEL}-${PYCUDA_VERSION}

mkdir -p ${PYCUDA_LABEL}
cd ${PYCUDA_LABEL}

wget https://files.pythonhosted.org/packages/78/09/9df5358ffb74d225243b56a65ffe196de481fcd8f731f55e41f2d5d36015/${PYCUDA_NAME}.tar.gz
tar -xvzf ${PYCUDA_NAME}.tar.gz
rm ${PYCUDA_NAME}.tar.gz

cd ${PYCUDA_NAME}
```


Set `default_lib_dirs` array in `setup.py`
------------------------------------------

```python
    default_lib_dirs = [
        "${CUDA_ROOT}/lib64",
        "${CUDA_ROOT}/lib64/stubs",
        "<NVHPC_ROOT>/math_libs/<CUDA_VERSION>/lib64",
        "<NVHPC_ROOT>/math_libs/<CUDA_VERSION>/lib64/stubs",
    ]
```
Note, you must replace `<NVHPC_ROOT>` in the string definitions above with the value
of the NVHPC_ROOT environment variable that was set when the `nvidia/nvhpc-nompi` module
was loaded. You must also replace `<CUDA_VERSION>` with the actual value held by the
CUDA_VERSION variable defined at the top of these instructions.


Build and install pycuda
------------------------

```
python configure.py --cuda-root=${NVHPC_ROOT}/cuda/${CUDA_VERSION}

CC=gcc CXX=g++ make
make install
make clean
```


Install general purpose python packages
---------------------------------------

```bash
cd ${MINICONDA_ROOT}

pip install scipy
pip install cupy-cuda116==10.3.1
pip install pandas
pip install dask
pip install memory_profiler
pip install matplotlib
pip install pyqt5
pip install numba
pip install graphviz
pip install nltk
pip install ipyparallel
pip install jupyter
pip install jupyterlab
pip install jupyterlab-server==2.10.3
pip install notebook
pip install sympy
pip install wandb
pip install gym
pip install termcolor
pip install h5py
pip install pyarrow
```


Install cudatoolkit
-------------------

```bash
cd ${MINICONDA_ROOT}

conda install -c anaconda cudatoolkit
```


Finish by deactivating the virtual environment
----------------------------------------------

```bash
conda deactivate
export PS1="[\u@\h \W]\$ "
```


Create `extend-venv-activate` script
------------------------------------

The Python environment described here is encapsulated as a TCL module file on Cirrus.
A user may build a local Python environment based on this module, `python/3.10.8-gpu`, which
means that module must be loaded whenever the local environment is activated.

The `extend-venv-activate` script ensures that this happens: it modifies the local environment's
activate script such that the `python/3.10.8-gpu` module is loaded during activation and unloaded
during deactivation.

The contents of the `extend-venv-activate` script are shown below. The file itself must be added
to the `${MINICONDA_ROOT}/bin` directory.

```bash
#!/bin/bash

# add extra activate commands
MARK="# you cannot run it directly"
CMDS="${MARK}\n\n"  
CMDS="${CMDS}module -s load python/3.10.8-gpu\n\n"
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
CMDS="${CMDS}${INDENT}module -s unload python/3.10.8-gpu"

sed -ri "s:${MARK}:${CMDS}:g" ${1}/bin/activate
```

Lastly, remember to set read and execute permission for all users, i.e., `chmod a+rx ${MINICONDA_ROOT}/bin/extend-venv-activate`.

See the link below for an example of how the `extend-venv-activate` script is called.

[https://docs.cirrus.ac.uk/user-guide/python/#installing-your-own-python-packages-with-pip](https://docs.cirrus.ac.uk/user-guide/python/#installing-your-own-python-packages-with-pip)
