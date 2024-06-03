Instructions for installing Graphviz 10.0.1 on ARCHER2
======================================================

These instructions show how to build Graphviz 10.0.1 for use on ARCHER2 (HPE Cray EX, AMD Zen2 7742)
using GCC 11.2.0.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/archer2-lmod/utils/core

GRAPHVIZ_LABEL=graphviz
GRAPHVIZ_VERSION=10.0.1
GRAPHVIZ_NAME=${GRAPHVIZ_LABEL}-${GRAPHVIZ_VERSION}
GRAPHVIZ_ROOT=${PRFX}/${GRAPHVIZ_LABEL}
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.


Download the Graphviz source code
---------------------------------

```bash
mkdir -p ${GRAPHVIZ_ROOT}
cd ${GRAPHVIZ_ROOT}

wget https://gitlab.com/api/v4/projects/4207231/packages/generic/${GRAPHVIZ_LABEL}-releases/${GRAPHVIZ_VERSION}/${GRAPHVIZ_NAME}.tar.gz

tar -xvzf ${GRAPHVIZ_NAME}.tar.gz
rm ${GRAPHVIZ_NAME}.tar.gz
```


Build Graphviz
--------------

```bash
module load PrgEnv-gnu

cd ${GRAPHVIZ_ROOT}/${GRAPHVIZ_NAME}

CC=cc ./configure --prefix=${GRAPHVIZ_ROOT}/${GRAPHVIZ_VERSION}

make -j 8
make -j 8 install
make clean
```
