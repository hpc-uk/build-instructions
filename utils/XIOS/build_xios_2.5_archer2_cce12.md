Instructions for building XIOS 2.5 on ARCHER2
=============================================

These instructions are for building XIOS 2.5 on the ARCHER2 full system (HPE Cray EX, AMD Zen2 7742) using CCE 12.


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


Download source code
--------------------

```bash
mkdir -p ${XIOS_ROOT}
cd ${XIOS_ROOT}

if [[ ! -d "${XIOS_NAME}" ]]; then
  svn co https://forge.ipsl.jussieu.fr/ioserver/svn/XIOS/branchs/${XIOS_NAME}
fi
```


Load modules
------------

```bash
module -q load cpe/21.09
module -q load cray-hdf5-parallel
module -q load cray-netcdf-hdf5parallel
module -q load xpmem
module -q load perftools-base

export LD_LIBRARY_PATH=${CRAY_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH}
```


Further environment setup
-------------------------

```bash
CRAY_VERSION_MAJOR=`echo ${CRAY_CC_VERSION} | cut -d'.' -f1`
COMPILER_LABEL=cce${CRAY_VERSION_MAJOR}
COMPILER_PATH=cce/${CRAY_VERSION_MAJOR}
MPI_LABEL=cmpich8
MPI_PATH=cmpich/8

MAKE_DIR=${XIOS_MAKE}
INSTALL_DIR=${XIOS_ROOT}/${XIOS_VERSION}/${COMPILER_PATH}/${MPI_PATH}
HOST_ARCH=X86_ARCHER2-${COMPILER_LABEL}-${MPI_LABEL}

ARCH_PRFX=${MAKE_DIR}/arch
ARCH_NAME=${HOST_ARCH}
```


Setup build architecture files
------------------------------

```bash
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
echo -e "# the Cray programming environment." >> ${ARCH_FCM}
echo -e "# The following modules must be loaded." >> ${ARCH_FCM}
echo -e "#    module -q load cpe/21.09" >> ${ARCH_FCM}
echo -e "#    module -q load cray-hdf5-parallel" >> ${ARCH_FCM}
echo -e "#    module -q load cray-netcdf-hdf5parallel" >> ${ARCH_FCM}
echo -e "#    module -q load xpmem" >> ${ARCH_FCM}
echo -e "#    module -q load perftools-base" >> ${ARCH_FCM}
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
```


Install XIOS
------------

```bash
mkdir -p ${INSTALL_DIR}
cp -r ${MAKE_DIR}/bin ${INSTALL_DIR}/
cp -r ${MAKE_DIR}/inc ${INSTALL_DIR}/
cp -r ${MAKE_DIR}/lib ${INSTALL_DIR}/

rm ${INSTALL_DIR}/bin/fcm_env.ksh
```
