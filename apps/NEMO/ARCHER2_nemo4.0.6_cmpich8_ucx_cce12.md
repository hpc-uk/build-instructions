Instructions for compiling NEMO-4.0.6 for ARCHER2
===============================================

These instructions are for compiling NEMO-4.0.6 on ARCHER2 (HPE Cray EX, AMD Zen2 7742) using the CCE 12 compilers, UCX and Cray MPICH 8.

We assume that the user has access to XIOS-2.5. Instructions for building XIOS-2.5 are found in this directory.  

Setup initial environment
-------------------------

```bash
PRFX=/path/to/work
NEMO_LABEL=nemo
NEMO_VERSION=4.0.6
NEMO_NAME=${NEMO_LABEL}-${NEMO_VERSION}
NEMO_ROOT=${PRFX}/${NEMO_LABEL}
NEMO_MAKE=${NEMO_ROOT}/${NEMO_NAME}
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.


Download and unpack NEMO
------------------------

```bash
mkdir -p ${NEMO_ROOT}
cd ${NEMO_ROOT}
svn co https://forge.ipsl.jussieu.fr/${NEMO_LABEL}/svn/${NEMO_LABEL^^}/releases/r${NEMO_VERSION:0:3}/r${NEMO_VERSION} ${NEMO_NAME}

cd ${NEMO_NAME}
```

Setup the module environment
----------------------------

```bash
module load cpe/21.09
module load cray-hdf5-parallel
module load cray-netcdf-hdf5parallel
```

Copy the ARCHER2 ARCH file
----------------------------

```bash
cp /work/z19/shared/NEMO/arch-X86_ARCHER2-Cray.fcm ./arch/
```


Edit files
----------

Edit line 480 of `/ext/FCM/lib/Fcm/Config.pm`:
```bash
change "FC_MODSEARCH => ''," to "FC_MODSEARCH => '-J',"
```

Edit line 35 of `./arch/arch-X86_ARCHER2-Cray.fcm`:
``` bash
change "%XIOS_HOME           /work/n01/shared/acc/xios-2.5" to "%XIOS_HOME           /path/to/xios/2.5/cmpich8-ucx/cce12"
```

Edit line 45 of `./arch/arch-X86_ARCHER2-Cray.fcm`:
``` bash
change "%CPP                 cpp" to "%CPP                 cpp -Dkey_nosignedzero"
```

We are now ready to build a NEMO configuration.


Setting up a test configuration
-------------------------------
```bash
cd ${NEMO_MAKE}

./makenemo -n GYRE_PISCES_TEST -r GYRE_PISCES -m X86_ARCHER2-Cray -j 16

cd ./cfgs/GYRE_PISCES_TEST/EXP00
rm ./nemo
cp ${NEMO_MAKE}/cfgs/GYRE_PISCES_TEST/BLD/bin/nemo.exe ./nemo
```

Link directory to XIOS

```bash
ln -s ${PRFX}/xios/2.5/cmpich8-ucx/cce12/bin/xios_server.exe xios_server.exe
```
