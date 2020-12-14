```bash
PRFX=/lustre/sw
GNUPAR_LABEL=gnu-parallel
GNUPAR_VERSION=20200522
GNUPAR_NAME=${GNUPAR_LABEL}-${GNUPAR_VERSION}

mkdir -p ${PRFX}/${GNUPAR_LABEL}
cd ${PRFX}/${GNUPAR_LABEL}

wget https://ftpmirror.gnu.org/parallel/parallel-${GNUPAR_VERSION}.tar.bz2
bzip2 -dc parallel-${GNUPAR_VERSION}.tar.bz2 | tar xvf -
rm parallel-${GNUPAR_VERSION}.tar.bz2
mv parallel-${GNUPAR_VERSION} ${GNUPAR_NAME}
cd ${GNUPAR_NAME}

module load gcc/6.3.0

./configure --prefix=${PRFX}/${GNUPAR_LABEL}/${GNUPAR_VERSION}
make
make install
make clean
```