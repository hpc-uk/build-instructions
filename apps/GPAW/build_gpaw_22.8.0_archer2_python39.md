Instructions for installing GPAW 22.8.0 on ARCHER2
==================================================

These instructions show how to build GPAW 22.8.0 for use on ARCHER2 (HPE Cray EX, AMD Zen2 7742)
using Python 3.9.4. The following will also [ASE](https://wiki.fysik.dtu.dk/ase/) 3.22.1 Python package.

GPAW 22.8.0 requires [libxc 6.1.0](https://github.com/hpc-uk/build-instructions/tree/main/libs/libxc).


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=${HOME/home/work}/libs

GPAW_LABEL=gpaw
GPAW_VERSION=22.8.0
GPAW_NAME=${GPAW_LABEL}-${GPAW_VERSION}
GPAW_ROOT=${PRFX}/${GPAW_LABEL}
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.
The following instructions assume that an installation of [libxc 6.1.0](https://github.com/hpc-uk/build-instructions/blob/main/libs/libxc/build_libxc_6.1.9_archer2_gcc11.md) exists directly
off the path indicated by `PRFX`.


Setup build environment
-----------------------

```bash
module -q restore
module -q load cpe/21.09
module -q load PrgEnv-gnu
module -q load cray-python
module -q load cray-fftw

LIBXC_ROOT=${PRFX}/libs/libxc/6.1.0

PYTHON_VER=`echo ${CRAY_PYTHON_LEVEL} | cut -d'.' -f1-2`
PYTHON_DIR=${PRFX}/${GPAW_LABEL}/${GPAW_VERSION}/python
PYTHON_BIN=${PYTHON_DIR}/${CRAY_PYTHON_LEVEL}/bin

mkdir -p ${PYTHON_BIN}

export PIP_CACHE_DIR=${PYTHON_DIR}/.cache/pip

export PYTHONUSERBASE=${PYTHON_DIR}/${CRAY_PYTHON_LEVEL}
export PATH=${PYTHONUSERBASE}/bin:${PATH}
export PYTHONPATH=${PYTHONUSERBASE}/lib/python${PYTHONVER}/site-packages:${PYTHONPATH}

pip install --user --upgrade pip
pip install --user cloudpickle
```


Build GPAW
----------

```bash
mkdir -p ${GPAW_ROOT}

cd ${GPAW_ROOT}
git clone -b ${GPAW_VERSION} https://gitlab.com/${GPAW_LABEL}/${GPAW_LABEL}.git
mv ${GPAW_LABEL} ${GPAW_NAME}
cd ${GPAW_NAME}

echo -e "libraries = ['sci_gnu_mpi_mp']" > ./siteconfig.py
echo -e "library_dirs = ['${CRAY_LIBSCI_PREFIX_DIR}/lib']\n" >> ./siteconfig.py
echo -e "scalapack = True\n" >> ./siteconfig.py
echo -e "extra_compile_args += ['-fopenmp']" >> ./siteconfig.py
echo -e "extra_link_args += ['-fopenmp']\n" >> ./siteconfig.py
echo -e "fftw = True" >> ./siteconfig.py
echo -e "libraries += ['fftw3']" >> ./siteconfig.py
echo -e "library_dirs += ['${FFTW_DIR}']" >> ./siteconfig.py
echo -e "include_dirs += ['${FFTW_INC}']\n" >> ./siteconfig.py
echo -e "libraries += ['xc']" >> ./siteconfig.py
echo -e "library_dirs += ['${LIBXC_ROOT}/lib']" >> ./siteconfig.py
echo -e "include_dirs += ['${LIBXC_ROOT}/include']\n" >> ./siteconfig.py
echo -e "compiler = 'cc'" >> ./siteconfig.py
echo -e "mpicompiler = 'cc'" >> ./siteconfig.py
echo -e "mpilinker = 'cc'" >> ./siteconfig.py

pip install --user .
```


Create GPAW activate script
---------------------------

```bash
echo -e "module -q restore" > ${PYTHON_BIN}/activate
echo -e "module -q load cpe/21.09" >> ${PYTHON_BIN}/activate
echo -e "module -q load PrgEnv-gnu" >> ${PYTHON_BIN}/activate
echo -e "module -q load cray-python" >> ${PYTHON_BIN}/activate
echo -e "module -q load cray-fftw\n" >> ${PYTHON_BIN}/activate

echo -e "source ${LIBXC_ROOT}/env.sh\n" >> ${PYTHON_BIN}/activate

echo -e "PRFX=\${HOME/home/work}" >> ${PYTHON_BIN}/activate
echo -e "GPAW_LABEL=${GPAW_LABEL}" >> ${PYTHON_BIN}/activate
echo -e "GPAW_VERSION=${GPAW_VERSION}" >> ${PYTHON_BIN}/activate
echo -e "GPAW_ROOT=\${PRFX}/\${GPAW_LABEL}\n" >> ${PYTHON_BIN}/activate

echo -e "PYTHON_VER=\`echo \${CRAY_PYTHON_LEVEL} | cut -d'.' -f1-2\`" >> ${PYTHON_BIN}/activate
echo -e "PYTHON_DIR=\${GPAW_ROOT}/\${GPAW_VERSION}/python" >> ${PYTHON_BIN}/activate
echo -e "PYTHON_BIN=\${PYTHON_DIR}/\${CRAY_PYTHON_LEVEL}/bin\n" >> ${PYTHON_BIN}/activate

echo -e "export PYTHONUSERBASE=\${PYTHON_DIR}/\${CRAY_PYTHON_LEVEL}\n" >> ${PYTHON_BIN}/activate

echo -e "export PATH=\${PYTHON_BIN}:\${PATH}" >> ${PYTHON_BIN}/activate
echo -e "export MANPATH=\${PYTHONUSERBASE}/lib/python\${PYTHON_VER}/site-packages:\${PYTHONPATH}" >> ${PYTHON_BIN}/activate
echo -e "export PYTHONPATH=\${PYTHONUSERBASE}/lib/python\${PYTHON_VER}/site-packages:\${PYTHONPATH}" >> ${PYTHON_BIN}/activate

chmod 700 ${PYTHON_BIN}/activate
```


Running GPAW
------------

You will need something like the following lines in your submission script in order
to run GPAW on the ARCHER2 compute nodes.

```bash

source ${PRFX}/libs/libxc/6.1.0/env.sh
source ${PRFX}/gpaw/22.8.0/python/3.9.4.1/bin/activate

```
