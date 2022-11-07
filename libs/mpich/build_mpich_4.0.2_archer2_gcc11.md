Instructions for building MPICH 4.0.2 on ARCHER2
================================================

These instructions are for building MPICH 4.0.2 on ARCHER2 (HPE Cray EX, AMD Zen2 7742) using gcc 11.2.0.
Two sets of instructions are provided, one that builds MPICH for the OpenFabrics interface (OFI) and the
other for the UCX communications interface.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work # e.g., PRFX=/work/y07/shared/libs/dev
MPICH_LABEL=mpich
MPICH_VERSION=4.0.2
MPICH_VERSION_MAJOR=`echo "${MPICH_VERSION}" | cut -d"." -f 1-2`
MPICH_NAME=${MPICH_LABEL}-${MPICH_VERSION}
MPICH_ROOT=${PRFX}/${MPICH_LABEL}

mkdir -p ${MPICH_ROOT}
cd ${MPICH_ROOT}

wget http://www.mpich.org/static/downloads/${MPICH_VERSION}/${MPICH_NAME}.tar.gz
tar -xzf ${MPICH_NAME}.tar.gz
rm ${MPICH_NAME}.tar.gz
cd ${MPICH_NAME}

module load cpe/21.09
module load PrgEnv-gnu
GNU_VERSION_MAJOR=`echo ${GNU_VERSION} | cut -d'.' -f1`

PMI_VERSION=6.0.13
PMI_ROOT=/opt/cray/pe/pmi/${PMI_VERSION}
PMI_HDRS_DIR=${PMI_ROOT}/include
PMI_LIBS_DIR=${PMI_ROOT}/lib
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.


Build and install MPICH for OFI
-------------------------------

```bash
OFI_ROOT=`pkg-config --variable=prefix libfabric`

MPICH_INSTALL_LABEL=${MPICH_VERSION}-ofi-gcc${GNU_VERSION_MAJOR}

./configure CC=cc CXX=CC FTN=ftn \
    CFLAGS="-I${PMI_HDRS_DIR} -O2 -march=znver2 -mno-avx512f" \
    FFLAGS="-fallow-argument-mismatch" FCFLAGS="-fallow-argument-mismatch" \
    LDFLAGS="-L${PMI_LIBS_DIR} -lpmi2" \
    --with-ofi=${OFI_ROOT} --with-pmi=pmi2 --with-pm=no \
    --enable-fast=all,O3 --with-slurm \
    --prefix=${MPICH_ROOT}/${MPICH_INSTALL_LABEL} \
    &> configure.log.${MPICH_INSTALL_LABEL}

mv config.log config.log.${MPICH_INSTALL_LABEL}

make -j 8
make -j 8 install
make -j 8 clean
```


Build and install MPICH for UCX
-------------------------------

Unfortunately, the present version of Cray UCX installed on ARCHER2 does not support
a particular ucx routine required by MPICH 4.0.2, namely `ucp_tag_msg_recv_nbx`,
and so MPICH 4.0.2 cannot be built using Cray UCX 2.7.0-1.

```bash
UCX_ROOT=/opt/cray/pe/cray-ucx/2.7.0-1/ucx

# setup link for numa library
mkdir -p ${MPICH_ROOT}/liblinks
ln -s /usr/lib64/libnuma.so.1.0.0 ${MPICH_ROOT}/liblinks/libnuma.so

module swap craype-network-ofi craype-network-ucx
# cray-mpich not required of course - second module swap simply being done for consistency
module swap cray-mpich cray-mpich-ucx

MPICH_INSTALL_LABEL=${MPICH_VERSION}-ucx-gcc${GNU_VERSION_MAJOR}

./configure CC=cc CXX=CC FTN=ftn \
    CFLAGS="-I${PMI_HDRS_DIR} -O2 -march=znver2 -mno-avx512f" \
    FFLAGS="-fallow-argument-mismatch" FCFLAGS="-fallow-argument-mismatch" \
    LDFLAGS="-L${PMI_LIBS_DIR} -lpmi2 -L${MPICH_ROOT}/liblinks -lnuma -L${UCX_ROOT}/lib -lucm -lucp -lucs -luct" \
    --with-ucx=${UCX_ROOT} --with-pmi=pmi2 --with-pm=no \
    --enable-fast=all,O3 --with-slurm \
    --prefix=${MPICH_ROOT}/${MPICH_INSTALL_LABEL} \
    &> configure.log.${MPICH_INSTALL_LABEL}

mv config.log config.log.${MPICH_INSTALL_LABEL}

make -j 8
make -j 8 install
make -j 8 clean
```
