Instructions for installing Graphviz 10.0.1 on Cirrus
=====================================================

These instructions show how to build Graphviz 10.0.1 for use on Cirrus (SGI ICE XA, Intel Xeon E5-2695)
using GCC 10.2.0.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/cirrus-software

GRAPHVIZ_LABEL=graphviz
GRAPHVIZ_VERSION=10.0.1
GRAPHVIZ_NAME=${GRAPHVIZ_LABEL}-${GRAPHVIZ_VERSION}
GRAPHVIZ_ROOT=${PRFX}/${GRAPHVIZ_LABEL}
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


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
module load gcc/10.2.0

cd ${GRAPHVIZ_ROOT}/${GRAPHVIZ_NAME}

./configure --prefix=${GRAPHVIZ_ROOT}/${GRAPHVIZ_VERSION}

make
make install
make clean
```
