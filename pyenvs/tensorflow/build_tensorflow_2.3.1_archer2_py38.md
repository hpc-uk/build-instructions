Instructions for installing TensorFlow 2.3.1 on ARCHER2
=======================================================

These instructions are for installing TensorFlow 2.3.1 on ARCHER2 (HPE Cray EX, AMD Zen2 7742) using Python 3.8.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work
TENSORFLOW_LABEL=tensorflow
TENSORFLOW_VERSION=2.3.1
TENSORFLOW_ROOT=${PRFX}/${TENSORFLOW_LABEL}

module load cray-python/3.8.5.0
module load craype-dl-plugin-py3/20.10.1

PYTHON_VERSION_MAJOR=`echo "${CRAY_PYTHON_VERSION}" | cut -d"." -f 1-2 | tr -d .`
TENSORFLOW_HOME=${TENSORFLOW_ROOT}/${TENSORFLOW_VERSION}-py${PYTHON_VERSION_MAJOR}
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.


Create and setup the TensorFlow virtual environment
---------------------------------------------------

```bash
python -m venv --system-site-packages ${TENSORFLOW_HOME}
. ${TENSORFLOW_HOME}/bin/activate
pip install --upgrade pip
```


Install the TensorFlow packages
-------------------------------

```bash
pip install "${TENSORFLOW_LABEL}==${TENSORFLOW_VERSION}"
pip install matplotlib
```


Finish by deactivating the virtual environment
----------------------------------------------

```bash
deactivate
```