Instructions for building a locally-installed custom Python environment on ARCHER2
==================================================================================
  
The instructions below show how to set up a locally-installed custom Python environment, one that includes
the packages provided by a centrally-installed Python module. You may want to do this in order to have
access to packages that have been specifically built for the ARCHER2 system, such as `mpi4py`. You can decide
which module to base your environment on by running `module avail cray-python` to see the available choices.

The instructions assume that the custom environment is named and versioned according to a single principal package.
If this is not the case, you will instead need to choose a name (and version) that best describes your custom environment.
You will also need to specify your own `pip install` commands (or `conda` equivalents).

Once the custom environment is installed, you can run the equivalent of `source ${PYTHON_BIN}/activate` to activate
the environment from within subsequent login sessions. You may want to do this if you need to change the packages
installed in the local environment. There is also a deactivate script for unloading the custom environment.

When running on the compute nodes, please make sure the `source ${PYTHON_BIN}/activate` command or similar
is called from the Slurm submission script.


Set the basic parameters
------------------------

```bash
INSTALL_PRFX=<install location>
PYPKG_LABEL=<name of principal python package>
PYPKG_VERSION=<version of principal python package>
PYTHON_MODULE_VERSION=<python module version>

echo -e "Install path starts with \"${INSTALL_PRFX}\"."
echo -e "Principal Python package is ${PYPKG_LABEL} ${PYPKG_VERSION}."
echo -e "Including packages from \"cray-python/${PYTHON_MODULE_VERSION}\" module.\n"
```

The user-supplied fields are indicated by angle brackets.
The install location is a simple file path.
The Python module version is the version of the Python module on which the custom environment is based.
Simply run `module avail cray-python` to see which versions are available.


Initialise environment variables and create install folders
-----------------------------------------------------------

```bash
DEACTIVATE_PATH=${PATH}
DEACTIVATE_LIBRARY_PATH=${LIBRARY_PATH}
DEACTIVATE_LD_LIBRARY_PATH=${LD_LIBRARY_PATH}
DEACTIVATE_PYTHONPATH=${PYTHONPATH}
DEACTIVATE_PYTHONUSERBASE=${PYTHONUSERBASE}
DEACTIVATE_XDG_CONFIG_HOME=${XDG_CONFIG_HOME}
DEACTIVATE_PIP_CACHE_DIR=${PIP_CACHE_DIR}
DEACTIVATE_CONDA_CACHE_DIR=${CONDA_CACHE_DIR}
DEACTIVATE_MPLCONFIGDIR=${MPLCONFIGDIR}

PYPKG_ROOT=${INSTALL_PRFX}/${PYPKG_LABEL}

mkdir -p ${PYPKG_ROOT}
cd ${PYPKG_ROOT}

module -s load cray-python/${PYTHON_MODULE_VERSION}

PYTHON_VER=`echo ${CRAY_PYTHON_LEVEL} | cut -d'.' -f1-2`
PYTHON_DIR=${PYPKG_ROOT}/${PYPKG_VERSION}/python
PYTHON_BIN=${PYTHON_DIR}/${PYTHON_MODULE_VERSION}/bin

export PYTHONUSERBASE=${PYTHON_DIR}/${PYTHON_MODULE_VERSION}
export PATH=${PYTHONUSERBASE}/bin:${PATH}
export PYTHONPATH=${PYTHONUSERBASE}/lib/python${PYTHON_VER}/site-packages:${PYTHONPATH}

export XDG_CONFIG_HOME=${PYTHON_DIR}/.config
export PIP_CACHE_DIR=${PYTHON_DIR}/.cache/pip
export CONDA_CACHE_DIR=${PYTHON_DIR}/.cache/conda
export MPLCONFIGDIR=${PYTHON_DIR}/.config/matplotlib

mkdir -p ${PYTHON_BIN}
mkdir -p ${XDG_CONFIG_HOME}
mkdir -p ${PIP_CACHE_DIR}
mkdir -p ${CONDA_CACHE_DIR}
mkdir -p ${MPLCONFIGDIR}
```


Installing package(s)
---------------------

```bash
pip install --user ${PYPKG_LABEL}==${PYPKG_VERSION}
```

You may need to alter the commands in this section according to your requirements.


Create activation script
------------------------

```bash
echo -e "#!/bin/bash\n" > ${PYTHON_BIN}/activate

echo -e "if [[ \"\${BASH_SOURCE[0]}\" == \"\${0}\" ]]; then" >> ${PYTHON_BIN}/activate
echo -e "  echo -e \"Error, activate script is not being sourced!\"" >> ${PYTHON_BIN}/activate
echo -e "  echo -e \"Please run \"source \${BASH_SOURCE[0]}\" instead.\"" >> ${PYTHON_BIN}/activate
echo -e "  exit 1" >> ${PYTHON_BIN}/activate
echo -e "fi\n" >> ${PYTHON_BIN}/activate

echo -e "INSTALL_PRFX=${INSTALL_PRFX}\n" >> ${PYTHON_BIN}/activate

echo -e "PYPKG_LABEL=${PYPKG_LABEL}" >> ${PYTHON_BIN}/activate
echo -e "PYPKG_VERSION=${PYPKG_VERSION}" >> ${PYTHON_BIN}/activate
echo -e "PYPKG_ROOT=\${INSTALL_PRFX}/\${PYPKG_LABEL}\n" >> ${PYTHON_BIN}/activate

echo -e "PYTHON_MODULE_VERSION=${PYTHON_MODULE_VERSION}\n" >> ${PYTHON_BIN}/activate

echo -e "module -s load cray-python/\${PYTHON_MODULE_VERSION}\n" >> ${PYTHON_BIN}/activate

echo -e "MODULE_LOADED=\`module info-loaded cray-python/\${PYTHON_MODULE_VERSION}\`" >> ${PYTHON_BIN}/activate
echo -e "if [[ \"\${MODULE_LOADED}\" != \"cray-python/\${PYTHON_MODULE_VERSION}\" ]]; then" >> ${PYTHON_BIN}/activate
echo -e "  echo -e \"Error, failed to load \"cray-python/\${PYTHON_MODULE_VERSION}\" module!\"" >> ${PYTHON_BIN}/activate
echo -e "  exit 1" >> ${PYTHON_BIN}/activate
echo -e "fi\n" >> ${PYTHON_BIN}/activate

echo -e "PYTHON_VER=\`echo \${CRAY_PYTHON_LEVEL} | cut -d'.' -f1-2\`" >> ${PYTHON_BIN}/activate
echo -e "PYTHON_DIR=\${PYPKG_ROOT}/\${PYPKG_VERSION}/python" >> ${PYTHON_BIN}/activate
echo -e "PYTHON_BIN=\${PYTHON_DIR}/\${PYTHON_MODULE_VERSION}/bin" >> ${PYTHON_BIN}/activate
echo -e "PYTHON_LIB=\${PYTHON_DIR}/\${PYTHON_MODULE_VERSION}/lib\n" >> ${PYTHON_BIN}/activate

echo -e "export PATH=\${PYTHON_BIN}:\${PATH}\n" >> ${PYTHON_BIN}/activate

echo -e "export LIBRARY_PATH=\${PYTHON_LIB}:\${LIBRARY_PATH}" >> ${PYTHON_BIN}/activate
echo -e "export LD_LIBRARY_PATH=\${PYTHON_LIB}:\${LD_LIBRARY_PATH}\n" >> ${PYTHON_BIN}/activate

echo -e "export PYTHONPATH=\${PYTHON_LIB}/python\${PYTHON_VER}/site-packages:\${PYTHONPATH}" >> ${PYTHON_BIN}/activate
echo -e "export PYTHONUSERBASE=\${PYTHON_DIR}/\${PYTHON_MODULE_VERSION}\n" >> ${PYTHON_BIN}/activate

echo -e "export XDG_CONFIG_HOME=\${PYTHON_DIR}/.config" >> ${PYTHON_BIN}/activate
echo -e "export PIP_CACHE_DIR=\${PYTHON_DIR}/.cache/pip" >> ${PYTHON_BIN}/activate
echo -e "export CONDA_CACHE_DIR=\${PYTHON_DIR}/.cache/conda" >> ${PYTHON_BIN}/activate
echo -e "export MPLCONFIGDIR=\${PYTHON_DIR}/.config/matplotlib" >> ${PYTHON_BIN}/activate

chmod 700 ${PYTHON_BIN}/activate
```


Create deactivation script
--------------------------

```bash
echo -e "#!/bin/bash\n" > ${PYTHON_BIN}/deactivate

echo -e "if [[ \"\${BASH_SOURCE[0]}\" == \"\${0}\" ]]; then" >> ${PYTHON_BIN}/deactivate
echo -e "  echo -e \"Error, deactivate script is not being sourced!\"" >> ${PYTHON_BIN}/deactivate
echo -e "  echo -e \"Please run \"source \${BASH_SOURCE[0]}\" instead.\"" >> ${PYTHON_BIN}/deactivate
echo -e "  exit 1" >> ${PYTHON_BIN}/deactivate
echo -e "fi\n" >> ${PYTHON_BIN}/deactivate

echo -e "PYTHON_MODULE_VERSION=${PYTHON_MODULE_VERSION}\n" >> ${PYTHON_BIN}/deactivate

echo -e "module -s unload cray-python/\${PYTHON_MODULE_VERSION}\n" >> ${PYTHON_BIN}/deactivate

echo -e "export PATH=${DEACTIVATE_PATH}" >> ${PYTHON_BIN}/deactivate
echo -e "export LIBRARY_PATH=${DEACTIVATE_LIBRARY_PATH}" >> ${PYTHON_BIN}/deactivate
echo -e "export LD_LIBRARY_PATH=${DEACTIVATE_LD_LIBRARY_PATH}" >> ${PYTHON_BIN}/deactivate
echo -e "export PYTHONPATH=${DEACTIVATE_PYTHONPATH}" >> ${PYTHON_BIN}/deactivate
echo -e "export PYTHONUSERBASE=${DEACTIVATE_PYTHONUSERBASE}\n" >> ${PYTHON_BIN}/deactivate

echo -e "export XDG_CONFIG_HOME=${DEACTIVATE_XDG_CONFIG_HOME}" >> ${PYTHON_BIN}/deactivate
echo -e "export PIP_CACHE_DIR=${DEACTIVATE_PIP_CACHE_DIR}" >> ${PYTHON_BIN}/deactivate
echo -e "export CONDA_CACHE_DIR=${DEACTIVATE_CONDA_CACHE_DIR}" >> ${PYTHON_BIN}/deactivate
echo -e "export MPLCONFIGDIR=${DEACTIVATE_MPLCONFIGDIR}" >> ${PYTHON_BIN}/deactivate

chmod 700 ${PYTHON_BIN}/deactivate
```
