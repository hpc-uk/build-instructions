Instructions for building XIOS r2528 on ARCHER2
===============================================

These instructions are for building XIOS trunk revision 2528 on the ARCHER2 full system (HPE Cray EX, AMD Zen2 7742) using AOCC 3.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work
XIOS_LABEL=xios
XIOS_REVISION=2528
XIOS_NAME=${XIOS_LABEL}-trunk-r${XIOS_REVISION}
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
  svn co -r ${XIOS_REVISION} https://forge.ipsl.jussieu.fr/ioserver/svn/XIOS2/trunk
  mv trunk ${XIOS_NAME}
fi
```


Load modules
------------

```bash
module -q load PrgEnv-aocc
module -q load cray-hdf5-parallel
module -q load cray-netcdf-hdf5parallel
module -q load xpmem
```


Further environment setup
-------------------------

```bash
AOCC_VERSION_MAJOR=`echo ${AOCC_VERSION} | cut -d'.' -f1`
COMPILER_LABEL=aocc${AOCC_VERSION_MAJOR}
COMPILER_PATH=aocc/${AOCC_VERSION_MAJOR}
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
echo -e "# the AOCC programming environment." >> ${ARCH_FCM}
echo -e "# The following modules must be loaded." >> ${ARCH_FCM}
echo -e "#    module -q load PrgEnv-aocc" >> ${ARCH_FCM}
echo -e "#    module -q load cray-hdf5-parallel" >> ${ARCH_FCM}
echo -e "#    module -q load cray-netcdf-hdf5parallel" >> ${ARCH_FCM}
echo -e "#    module -q load xpmem" >> ${ARCH_FCM}
echo -e "%CCOMPILER      CC" >> ${ARCH_FCM}
echo -e "%FCOMPILER      ftn" >> ${ARCH_FCM}
echo -e "%LINKER         ftn\n" >> ${ARCH_FCM}
echo -e "%BASE_CFLAGS    -D__NONE__" >> ${ARCH_FCM}
echo -e "%PROD_CFLAGS    -O3 -DBOOST_DISABLE_ASSERTS -std=c++11" >> ${ARCH_FCM}
echo -e "%DEV_CFLAGS     -g -O2 -std=c++11" >> ${ARCH_FCM}
echo -e "%DEBUG_CFLAGS   -g -O0 -std=c++11\n" >> ${ARCH_FCM}
echo -e "%BASE_FFLAGS    -D__NONE__" >> ${ARCH_FCM}
echo -e "%PROD_FFLAGS    -O3 -lmpichf90" >> ${ARCH_FCM}
echo -e "%DEV_FFLAGS     -g -O2 -lmpichf90" >> ${ARCH_FCM}
echo -e "%DEBUG_FFLAGS   -g -O0 -lmpichf90\n" >> ${ARCH_FCM}
echo -e "%BASE_INC       -D__NONE__" >> ${ARCH_FCM}
echo -e "%BASE_LD        -lstdc++\n" >> ${ARCH_FCM}
echo -e "%CPP            cpp" >> ${ARCH_FCM}
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
