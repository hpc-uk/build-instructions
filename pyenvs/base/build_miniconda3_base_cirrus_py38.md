Instructions for building a general purpose Miniconda3 environment on Cirrus
============================================================================

These instructions are for building a general purpose (or base-level) Miniconda3 environment
on Cirrus (SGI ICE XA, Intel Xeon Broadwell (CPU) and Cascade Lake (GPU)) using Python 3.8.

As the target machine is Cirrus, the Miniconda3 environment is setup with GPU support in the
form of pycuda 2021.1 and CUDA 11.2. MPI support is provided by mpi4py 3.0.3 and OpenMPI 4.1.0
; the OpenMPI libraries having been built against CUDA 11.2 and UCX 1.9.0.

In addition, the environment provides a suite of general purpose packages (e.g., numpy, scipy,
pandas and matplotlib) and also supports interactive parallel python using Jupyter notebooks.

Other Miniconda3 environments whose purposes are more tightly defined are expected to be based
on this module.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/lustre/sw
cd ${PRFX}

CUDA_VERSION=11.2
OPENMPI_VERSION=4.1.0
BOOST_VERSION=1.73.0

module load nvidia/cuda-${CUDA_VERSION}
module load nvidia/mathlibs-${CUDA_VERSION}
module load openmpi/${OPENMPI_VERSION}-cuda-${CUDA_VERSION}
module load boost/${BOOST_VERSION}

PYTHON_LABEL=py38
MINICONDA_TAG=miniconda
MINICONDA_LABEL=${MINICONDA_TAG}3
MINICONDA_VERSION=4.9.2
MINICONDA_ROOT=${PRFX}/${MINICONDA_LABEL}/${MINICONDA_VERSION}-${PYTHON_LABEL}

MPI4PY_LABEL=mpi4py
MPI4PY_VERSION=3.0.3
MPI4PY_ROOT=${MINICONDA_ROOT}/${MPI4PY_LABEL}/${MPI4PY_VERSION}-ompi-${OPENMPI_VERSION}
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Create and setup a Miniconda3 virtual environment
-------------------------------------------------

```bash
cd ${PRFX}

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
conda update -y -n root --all

conda deactivate
```


Build and install mpi4py using OpenMPI 4.1.0
--------------------------------------------

```bash
cd ${MINICONDA_ROOT}

PYTHON_LABEL_LONG=python${PYTHON_LABEL:2:1}.${PYTHON_LABEL:3:1}

MPI4PY_NAME=${MPI4PY_LABEL}-${MPI4PY_VERSION}

. ${MINICONDA_ROOT}/activate.sh

mkdir -p ${MPI4PY_LABEL}
cd ${MPI4PY_LABEL}

wget https://github.com/${MPI4PY_LABEL}/${MPI4PY_LABEL}/archive/${MPI4PY_VERSION}.tar.gz
tar -xvzf ${MPI4PY_VERSION}.tar.gz
rm ${MPI4PY_VERSION}.tar.gz

cd ${MPI4PY_NAME}

python setup.py build
python setup.py install --prefix=${MPI4PY_ROOT}
python setup.py clean --all

echo "ROOT=${MPI4PY_ROOT}" > ${MPI4PY_ROOT}/env.sh
echo "export LIBRARY_PATH=\${ROOT}/lib:\${LIBRARY_PATH}" >> ${MPI4PY_ROOT}/env.sh
echo "export LD_LIBRARY_PATH=\${ROOT}/lib:\${LD_LIBRARY_PATH}" >> ${MPI4PY_ROOT}/env.sh
echo "export PYTHONPATH=\${ROOT}/lib/${PYTHON_LABEL_LONG}/site-packages:\${PYTHONPATH}" >> ${MPI4PY_ROOT}/env.sh
. ${MPI4PY_ROOT}/env.sh

conda deactivate
```


Build and install pycuda
------------------------

```bash
cd ${MINICONDA_ROOT}

. ${MINICONDA_ROOT}/activate.sh

if [[ ${LD_LIBRARY_PATH} != *"${MPI4PY_ROOT}"* ]]; then
  . ${MPI4PY_ROOT}/env.sh
fi

PYCUDA_LABEL=pycuda
PYCUDA_VERSION=2021.1
PYCUDA_NAME=${PYCUDA_LABEL}-${PYCUDA_VERSION}

mkdir -p ${PYCUDA_LABEL}
cd ${PYCUDA_LABEL}

wget https://files.pythonhosted.org/packages/5a/56/4682a5118a234d15aa1c8768a528aac4858c7b04d2674e18d586d3dfda04/${PYCUDA_NAME}.tar.gz
tar -xvzf ${PYCUDA_NAME}.tar.gz
rm ${PYCUDA_NAME}.tar.gz

cd ${PYCUDA_NAME}

python configure.py --cuda-root=${CUDAROOT} --no-use-shipped-boost --boost-python-libname=boost_python-py36 --ldflags="-L${CUDAROOT}/targets/x86_64-linux/lib/stubs"
make
make install
make clean

conda deactivate
```

Notice that the python configure command for pycuda has one anomalous setting, the `py36` suffix used for the boost python library name.
This is not a mistake; it ia merely a workaround required to get pycuda to build.


Install general purpose python packages
---------------------------------------

```bash
cd ${MINICONDA_ROOT}

. ${MINICONDA_ROOT}/activate.sh

if [[ ${LD_LIBRARY_PATH} != *"${MPI4PY_ROOT}"* ]]; then
  . ${MPI4PY_ROOT}/env.sh
fi

pip install scipy
pip install matplotlib
pip install pandas
pip install ipyparallel
pip install notebook
pip install sympy
pip install graphviz

conda deactivate
```