Instructions for compiling XIOS-2.5 for ARCHER2
===============================================

These instructions are for compiling XIOS-2.5 on ARCHER2 (HPE Cray EX, AMD Zen2 7742) using the CCE 12 compilers, UCX and Cray MPICH 8.

Setup initial environment
-------------------------

```bash
PRFX=/path/to/work
XIOS_LABEL=xios
XIOS_VERSION=2.5
XIOS_NAME=${XIOS_LABEL}-${XIOS_VERSION}
XIOS_ROOT=${PRFX}/${XIOS_LABEL}
XIOS_MAKE=${XIOS_ROOT}/${XIOS_NAME}

```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.


Download and unpack XIOS
------------------------

```bash
mkdir -p ${XIOS_ROOT}
cd ${XIOS_ROOT}

svn co https://forge.ipsl.jussieu.fr/ioserver/svn/XIOS/branchs/${XIOS_NAME}
```

Setup the module environment
----------------------------

```bash
module load cpe/21.09
module load cray-hdf5-parallel
module load cray-netcdf-hdf5parallel
```


Setup the architecture files
----------------------------

```bash
CRAY_VERSION_MAJOR=`echo ${CRAY_CC_VERSION} | cut -d'.' -f1`
COMPILER_LABEL=cce${CRAY_VERSION_MAJOR}
MPI_LABEL=cmpich8-ucx

MAKE_DIR=${XIOS_MAKE}
INSTALL_DIR=${XIOS_ROOT}/${XIOS_VERSION}/${MPI_LABEL}/${COMPILER_LABEL}
HOST_ARCH=X86_ARCHER2-Cray

ARCH_PRFX=${MAKE_DIR}/arch
ARCH_NAME=${HOST_ARCH}


ARCH_ENV=${ARCH_PRFX}/arch-${ARCH_NAME}.env
touch ${ARCH_ENV}

ARCH_PATH=${ARCH_PRFX}/arch-${ARCH_NAME}.path
echo -e "NETCDF_INCDIR=\"-I\${NETCDF_DIR}/include\"" > ${ARCH_PATH}
echo -e "NETCDF_LIBDIR=\"-L\${NETCDF_DIR}/lib\"" >> ${ARCH_PATH}
echo -e "NETCDF_LIB=\"-lnetcdf -lnetcdff\"\n" >> ${ARCH_PATH}
echo -e "MPI_INCDIR=\"\"" >> ${ARCH_PATH}
echo -e "MPI_LIBDIR=\"\"" >> ${ARCH_PATH}
echo -e "MPI_LIB=\"\"\n" >> ${ARCH_PATH}
echo -e "HDF5_INCDIR=\"-I\${HDF5_DIR}/include\"" >> ${ARCH_PATH}
echo -e "HDF5_LIBDIR=\"-L\${HDF5_DIR}/lib\"" >> ${ARCH_PATH}
echo -e "HDF5_LIB=\"-lhdf5_hl -lhdf5 -lz -lcurl\"\n" >> ${ARCH_PATH}
echo -e "#BOOST_INCDIR=\"-I\${BOOST_INCDIR}\"" >> ${ARCH_PATH}
echo -e "#BOOST_LIBDIR=\"-L\${BOOST_LIBDIR}\"" >> ${ARCH_PATH}
echo -e "#BOOST_LIB=\"\"\n" >> ${ARCH_PATH}
echo -e "#BLITZ_INCDIR=\"-I\${BLITZ_INCDIR}\"" >> ${ARCH_PATH}
echo -e "#BLITZ_LIBDIR=\"-L\${BLITZ_LIBDIR}\"" >> ${ARCH_PATH}
echo -e "#BLITZ_LIB=\"\"\n" >> ${ARCH_PATH}
echo -e "OASIS_INCDIR=\"\"" >> ${ARCH_PATH}
echo -e "OASIS_LIBDIR=\"\"" >> ${ARCH_PATH}
echo -e "OASIS_LIB=\"\"\n" >> ${ARCH_PATH}
echo -e "#only for MEMTRACK debuging : developer only" >> ${ARCH_PATH}
echo -e "#ADDR2LINE_LIBDIR=\"-L\${WORKDIR}/ADDR2LINE_LIB\"" >> ${ARCH_PATH}
echo -e "#ADDR2LINE_LIB=\"-laddr2line\"" >> ${ARCH_PATH}

ARCH_FCM=${ARCH_PRFX}/arch-${ARCH_NAME}.fcm
echo -e "# Cray EX build instructions for XIOS/${XIOS_NAME}" > ${ARCH_FCM}
echo -e "# These files have been tested on Archer2 (HPE Cray EX, AMD Zen2 7742) using" >> ${ARCH_FCM}
echo -e "# the Cray (ucx) programming environment." >> ${ARCH_FCM}
echo -e "# One must also restore the following module." >> ${ARCH_FCM}
echo -e "#    module -s restore /work/n01/shared/acc/n01_modules/ucx_env" >> ${ARCH_FCM}
echo -e "#    module -s load cpe/21.03" >> ${ARCH_FCM}
echo -e "#    export LD_LIBRARY_PATH=\${CRAY_LD_LIBRARY_PATH}:\${LD_LIBRARY_PATH}" >> ${ARCH_FCM}
echo -e "%CCOMPILER      CC" >> ${ARCH_FCM}
echo -e "%FCOMPILER      ftn" >> ${ARCH_FCM}
echo -e "%LINKER         ftn\n" >> ${ARCH_FCM}
echo -e "%BASE_CFLAGS    " >> ${ARCH_FCM}
echo -e "%PROD_CFLAGS    -O2 -D BOOST_DISABLE_ASSERTS -std=c++98" >> ${ARCH_FCM}
echo -e "%DEV_CFLAGS     -g -std=c++98" >> ${ARCH_FCM}
echo -e "%DEBUG_CFLAGS   -DBZ_DEBUG -g -traceback -fno-inline -std=c++98\n" >> ${ARCH_FCM}
echo -e "%BASE_FFLAGS    -D__NONE__" >> ${ARCH_FCM}
echo -e "%PROD_FFLAGS    -O2 -hflex_mp=intolerant -s integer32 -s real64 -lmpifort_cray" >> ${ARCH_FCM}
echo -e "%DEV_FFLAGS     -g" >> ${ARCH_FCM}
echo -e "%DEBUG_FFLAGS   -g -traceback\n" >> ${ARCH_FCM}
echo -e "%BASE_INC       -D__NONE__" >> ${ARCH_FCM}
echo -e "%BASE_LD        -lstdc++\n" >> ${ARCH_FCM}
echo -e "%CPP            cpp -EP" >> ${ARCH_FCM}
echo -e "%FPP            cpp -P" >> ${ARCH_FCM}
echo -e "%MAKE           gmake" >> ${ARCH_FCM}
```


Build XIOS
----------

```bash
cd ${MAKE_DIR}
./make_xios --full --arch ${HOST_ARCH}

mkdir -p ${INSTALL_DIR}
cp -r ${MAKE_DIR}/bin ${INSTALL_DIR}/
cp -r ${MAKE_DIR}/inc ${INSTALL_DIR}/
cp -r ${MAKE_DIR}/lib ${INSTALL_DIR}/
```
