Instructions for building PyFR 1.10.0 on Cirrus
===============================================

These instructions are for building PyFR 1.10.0 on Cirrus (SGI ICE XA, Intel Xeon Broadwell (CPU) and Cascade Lake (GPU)) using Python 3.8.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Create and setup a Miniconda3 virtual environment
-------------------------------------------------

```bash
mkdir miniconda3
cd miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-py38_4.9.2-Linux-x86_64.sh
bash Miniconda3-py38_4.9.2-Linux-x86_64.sh -b -f -p ${WORKDIR}/miniconda3/4.9.2
rm Miniconda3-py38_4.9.2-Linux-x86_64.sh
MINICONDA3_ROOT=${PRFX}/miniconda3/4.9.2
cd ${MINICONDA3_ROOT}

PATH=${MINICONDA3_ROOT}/bin:${PATH}
conda init --dry-run --verbose > activate.sh
conda_env_start=`grep -n "# >>> conda initialize >>>" activate.sh | cut -d':' -f 1`
conda_env_stop=`grep -n "# <<< conda initialize <<<" activate.sh | cut -d':' -f 1`

echo "sed -n '${conda_env_start},${conda_env_stop}p' activate.sh > activate2.sh" > sed.sh
echo "sed 's/^.//' activate2.sh > activate.sh" >> sed.sh
echo "rm activate2.sh" >> sed.sh
. ./sed.sh
rm ./sed.sh

. ${MINICONDA3_ROOT}/activate.sh
conda update -y -n root --all
```


Build and install mpi4py using OpenMPI 4.1.0
--------------------------------------------

```bash
cd ${PRFX}

mkdir mpi4py
cd mpi4py
wget https://github.com/mpi4py/mpi4py/archive/3.0.3.tar.gz
tar -xvzf 3.0.3.tar.gz
rm 3.0.3.tar.gz

cd mpi4py-3.0.3

module load openmpi/4.1.0-ucx-gcc8

MPI4PY_ROOT=${PRFX}/mpi4py/3.0.3-ompi-ucx
python setup.py clean --all
python setup.py build
python setup.py install --prefix=${MPI4PY_ROOT}

echo "ROOT=${MPI4PY_ROOT}" > ${MPI4PY_ROOT}/env.sh
echo "export LIBRARY_PATH=\${ROOT}/lib:\${LIBRARY_PATH}" >> ${MPI4PY_ROOT}/env.sh
echo "export LD_LIBRARY_PATH=\${ROOT}/lib:\${LD_LIBRARY_PATH}" >> ${MPI4PY_ROOT}/env.sh
echo "export PYTHONPATH=\${ROOT}/lib/python3.8/site-packages:\${PYTHONPATH}" >> ${MPI4PY_ROOT}/env.sh
. ${MPI4PY_ROOT}/env.sh
```


Build and install pycuda
------------------------

```bash
cd ${PRFX}

mkdir pycuda
cd pycuda

wget https://files.pythonhosted.org/packages/46/61/47d3235a4c13eec5a5f03594ddb268f4858734e02980afbcd806e6242fa5/pycuda-2020.1.tar.gz
tar -xvzf pycuda-2020.1.tar.gz
rm pycuda-2020.1.tar.gz

cd pycuda-2020.1
module load nvidia/cuda-10.2
module load nvidia/mathlibs-10.2
module load boost/1.73.0

python configure.py --cuda-root=${CUDAROOT} --no-use-shipped-boost --boost-python-libname=boost_python-py36 --ldflags="-L/lustre/sw/nvidia/hpcsdk/Linux_x86_64/20.9/cuda/11.0/targets/x86_64-linux/lib/stubs"
make
make install
```


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
