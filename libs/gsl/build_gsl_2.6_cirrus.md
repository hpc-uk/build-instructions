```bash
  
PRFX=/lustre/sw
GSL_LABEL=gsl
GSL_VERSION=2.6
GSL_NAME=${GSL_LABEL}-${GSL_VERSION}

mkdir -p ${PRFX}/${GSL_LABEL}
cd ${PRFX}/${GSL_LABEL}

wget http://mirror.koddos.net/gnu/${GSL_LABEL}/${GSL_NAME}.tar.gz
tar -xvzf ${GSL_NAME}.tar.gz
rm ${GSL_NAME}.tar.gz
cd ${GSL_NAME}

module load gcc/6.3.0

./configure CC=gcc --prefix=${PRFX}/${GSL_LABEL}/${GSL_VERSION}
make
make check
make install
make clean
```