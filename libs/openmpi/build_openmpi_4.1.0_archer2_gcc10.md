Instructions for building OpenMPI 4.1.0 on ARCHER2
==================================================

These instructions are for building OpenMPI 4.1.0 on ARCHER2 (HPE Cray EX, AMD Zen2 7742) using gcc 10.1.0.
Two sets of instructions are provided, one that builds OpenMPI for the OpenFabrics interface (OFI) and the
other for the UCX communications interface.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work
OPENMPI_LABEL=openmpi
OPENMPI_VERSION=4.1.0
OPENMPI_VERSION_MAJOR=`echo "${OPENMPI_VERSION}" | cut -d"." -f 1-2`
OPENMPI_NAME=${OPENMPI_LABEL}-${OPENMPI_VERSION}
OPENMPI_ROOT=${PRFX}/${OPENMPI_LABEL}

mkdir -p ${OPENMPI_ROOT}
cd ${OPENMPI_ROOT}

wget https://download.open-mpi.org/release/open-mpi/v${OPENMPI_VERSION_MAJOR}/${OPENMPI_NAME}.tar.gz
tar -xzf ${OPENMPI_NAME}.tar.gz
rm ${OPENMPI_NAME}.tar.gz
cd ${OPENMPI_NAME}
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Build and install OpenMPI for OFI
---------------------------------

```bash
module -s restore PrgEnv-gnu
GNU_VERSION_MAJOR=`echo ${GNU_VERSION} | cut -d'.' -f1`

OPENMPI_INSTALL_LABEL=${OPENMPI_VERSION}-ofi-gcc${GNU_VERSION_MAJOR}

./configure CC=cc CXX=CC FTN=ftn CFLAGS="-march=znver2 -mno-avx512f" \
    --enable-mpi1-compatibility --enable-mpi-fortran \
    --with-ofi=/opt/cray/libfabric/1.11.0.0.233 \
    --with-singularity \
    --prefix=${OPENMPI_ROOT}/${OPENMPI_INSTALL_LABEL} \
    &> configure.log.${OPENMPI_INSTALL_LABEL}

mv config.log config.log.${OPENMPI_INSTALL_LABEL}

make
make install
make clean
```


Build and install OpenMPI for UCX
---------------------------------

```bash
module -s restore PrgEnv-gnu
GNU_VERSION_MAJOR=`echo ${GNU_VERSION} | cut -d'.' -f1`

module unload craype-network-ofi
module load craype-network-ucx
module load libfabric/1.11.0.0.233

OPENMPI_INSTALL_LABEL=${OPENMPI_VERSION}-ucx-gcc${GNU_VERSION_MAJOR}

./configure CC=cc CXX=CC FTN=ftn CFLAGS="-march=znver2 -mno-avx512f" LDFLAGS="-L${OPENMPI_ROOT}/liblinks" \
    --enable-mpi1-compatibility --enable-mpi-fortran \
    --with-ucx=/opt/cray/cray-ucx/2.6.0-3/ucx \
    --with-singularity \
    --prefix=${OPENMPI_ROOT}/${OPENMPI_INSTALL_LABEL} \
    &> configure.log.${OPENMPI_INSTALL_LABEL}

mv config.log config.log.${OPENMPI_INSTALL_LABEL}

make
make install
make clean
```
