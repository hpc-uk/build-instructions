Instructions for building a Miniconda3 environment suitable for Cirrus GPU nodes
================================================================================

These instructions show how to build Miniconda3 environment (based on Python 3.9.13) for the Cirrus GPU nodes
(Cascade Lake, NVIDIA Tesla V100-SXM2-16GB), one that supports parallel computation.

The environment features mpi4py 3.1.3 (OpenMPI 4.1.4 with ucx 1.9.0 and CUDA 11.6) with pycuda 2022.1
and cupy 10.6.0. It also provides a suite of packages pertinent to parallel processing and numerical analysis,
e.g., dask, ipyparallel, jupyter, matplotlib, numpy, pandas and scipy.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/mnt/lustre/indy2lfs/sw
cd ${PRFX}

NVHPC_VERSION=22.2
CUDA_VERSION=11.6
OPENMPI_VERSION=4.1.4
BOOST_VERSION=1.73.0

module load boost/${BOOST_VERSION}
module load nvidia/nvhpc-nompi/${NVHPC_VERSION}
module load openmpi/${OPENMPI_VERSION}-cuda-${CUDA_VERSION}

MPI4PY_LABEL=mpi4py
MPI4PY_VERSION=3.1.3

PYTHON_LABEL=py39
MINICONDA_TAG=miniconda
MINICONDA_LABEL=${MINICONDA_TAG}3
MINICONDA_VERSION=4.12.0
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


Build and install mpi4py using OpenMPI 4.1.4-cuda-11.6
------------------------------------------------------

```bash
cd ${MINICONDA_ROOT}

MPI4PY_NAME=${MPI4PY_LABEL}-${MPI4PY_VERSION}

mkdir -p ${MPI4PY_LABEL}
cd ${MPI4PY_LABEL}

wget https://github.com/${MPI4PY_LABEL}/${MPI4PY_LABEL}/archive/${MPI4PY_VERSION}.tar.gz
tar -xvzf ${MPI4PY_VERSION}.tar.gz
rm ${MPI4PY_VERSION}.tar.gz

cd ${MPI4PY_NAME}

python setup.py build
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
PYCUDA_VERSION=2022.1
PYCUDA_NAME=${PYCUDA_LABEL}-${PYCUDA_VERSION}

mkdir -p ${PYCUDA_LABEL}
cd ${PYCUDA_LABEL}

wget https://files.pythonhosted.org/packages/2d/1f/48a3a5b2c715345e7af1e09361100bd98c3d72b4025371692ab233f523d3/${PYCUDA_NAME}.tar.gz
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
python configure.py --cuda-root=${NVHPC_ROOT}/cuda/${CUDA_VERSION} \
                    --no-use-shipped-boost --boost-python-libname=boost_python-py36

CC=gcc CXX=g++ make
make install
make clean
```

Note that the python configure command for pycuda has one anomalous setting, the `py36` suffix used for the boost python library name.
This is not a mistake; it is merely a workaround required to get pycuda to build.


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
