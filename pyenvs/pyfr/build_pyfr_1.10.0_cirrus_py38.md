Instructions for building PyFR 1.10.0 on Cirrus
===============================================

These instructions are for building PyFR 1.10.0 on Cirrus (SGI ICE XA, Intel Xeon Broadwell (CPU) and Cascade Lake (GPU)) using Python 3.8.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work
cd ${PRFX}
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Create and setup a Miniconda3 virtual environment
-------------------------------------------------

```bash
PYTHON_LABEL=py38
PYTHON_LABEL_LONG=python${PYTHON_LABEL:2:1}.${PYTHON_LABEL:3:1}

MINICONDA_TAG=miniconda
MINICONDA_LABEL=${MINICONDA_TAG}3
MINICONDA_TITLE=${MINICONDA_LABEL^}
MINICONDA_VERSION=4.9.2
MINICONDA_ROOT=${PRFX}/${MINICONDA_LABEL}/${MINICONDA_VERSION}-${PYTHON_LABEL}
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
```


Build and install mpi4py using OpenMPI 4.1.0
--------------------------------------------

```bash
cd ${PRFX}

MPI4PY_LABEL=mpi4py
MPI4PY_VERSION=3.0.3
MPI4PY_NAME=${MPI4PY_LABEL}-${MPI4PY_VERSION}

OPENMPI_VERSION=4.1.0
CUDA_VERSION=10.2

module load openmpi/${OPENMPI_VERSION}-cuda-${CUDA_VERSION}

mkdir -p ${MPI4PY_LABEL}
cd ${MPI4PY_LABEL}

wget https://github.com/${MPI4PY_LABEL}/${MPI4PY_LABEL}/archive/${MPI4PY_VERSION}.tar.gz
tar -xvzf ${MPI4PY_VERSION}.tar.gz
rm ${MPI4PY_VERSION}.tar.gz

cd ${MPI4PY_NAME}

MPI4PY_ROOT=${PRFX}/${MPI4PY_LABEL}/${MPI4PY_VERSION}-ompi-${OPENMPI_VERSION}
python setup.py clean --all
python setup.py build
python setup.py install --prefix=${MPI4PY_ROOT}

echo "ROOT=${MPI4PY_ROOT}" > ${MPI4PY_ROOT}/env.sh
echo "export LIBRARY_PATH=\${ROOT}/lib:\${LIBRARY_PATH}" >> ${MPI4PY_ROOT}/env.sh
echo "export LD_LIBRARY_PATH=\${ROOT}/lib:\${LD_LIBRARY_PATH}" >> ${MPI4PY_ROOT}/env.sh
echo "export PYTHONPATH=\${ROOT}/lib/${PYTHON_LABEL_LONG}/site-packages:\${PYTHONPATH}" >> ${MPI4PY_ROOT}/env.sh
. ${MPI4PY_ROOT}/env.sh
```


Build and install pycuda
------------------------

```bash
cd ${PRFX}

PYCUDA_LABEL=pycuda
PYCUDA_VERSION=2020.1
PYCUDA_NAME=${PYCUDA_LABEL}-${PYCUDA_VERSION}

CUDA_VERSION=10.2

module load nvidia/cuda-${CUDA_VERSION}
module load nvidia/mathlibs-${CUDA_VERSION}
module load boost/1.73.0

mkdir -p ${PYCUDA_LABEL}
cd ${PYCUDA_LABEL}

wget https://files.pythonhosted.org/packages/46/61/47d3235a4c13eec5a5f03594ddb268f4858734e02980afbcd806e6242fa5/${PYCUDA_NAME}.tar.gz
tar -xvzf ${PYCUDA_NAME}.tar.gz
rm ${PYCUDA_NAME}.tar.gz

cd ${PYCUDA_NAME}

python configure.py --cuda-root=${CUDAROOT} --no-use-shipped-boost --boost-python-libname=boost_python-py36 --ldflags="-L/lustre/sw/nvidia/hpcsdk/Linux_x86_64/20.9/cuda/11.0/targets/x86_64-linux/lib/stubs"
make
make install
```

Notice that the python configure command for pycuda has two anomalous settings, the `py36` suffix used for the boost python library name and the `11.0` version tag used in the path to the CUDA stub libraries.
These are not mistakes merely workarounds required to get pycuda to build. These settings do not appear to compromise the PyFR installation (e.g., scaling runs perform as expected).


Install other python packages required by PyFR
----------------------------------------------

```bash
pip install appdirs
pip install gimmik
pip install h5py
pip install mako
pip install mpi4py
pip install numpy
pip install pytools
```


Install PyFR itself
-------------------
```bash
pip install pyfr
```


Finish by deactivating the virtual environment
----------------------------------------------

```bash
conda deactivate
```
