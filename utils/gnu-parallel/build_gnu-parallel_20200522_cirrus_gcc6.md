Instructions for building GNU Parallel 20200522 on Cirrus
=========================================================

These instructions are for building GNU Parallel 20200522 on Cirrus (Intel Xeon E5-2695, Broadwell) using GCC 6.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., /lustre/sw

GNUPAR_LABEL=gnu-parallel
GNUPAR_VERSION=20200522
GNUPAR_NAME=${GNUPAR_LABEL}-${GNUPAR_VERSION}

mkdir -p ${PRFX}/${GNUPAR_LABEL}
cd ${PRFX}/${GNUPAR_LABEL}

module load gcc/6.3.0
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Download source code
--------------------

```bash
wget https://ftpmirror.gnu.org/parallel/parallel-${GNUPAR_VERSION}.tar.bz2

bzip2 -dc parallel-${GNUPAR_VERSION}.tar.bz2 | tar xvf -

rm parallel-${GNUPAR_VERSION}.tar.bz2
mv parallel-${GNUPAR_VERSION} ${GNUPAR_NAME}
cd ${GNUPAR_NAME}
```


Configure and build GNU Parallel
--------------------------------

```bash
./configure --prefix=${PRFX}/${GNUPAR_LABEL}/${GNUPAR_VERSION}

make
make install
make clean
```
