Instructions for building NEMO 4.2.0 on ARCHER2
===============================================

These instructions are for building NEMO 4.2.0 on the ARCHER2 full system (HPE Cray EX, AMD Zen2 7742) using GCC 11.

We assume that the user has access to XIOS trunk revision 2528.
Instructions for building XIOS r2528 can be found at [../../utils/XIOS/build_xios_r2528_archer2_gcc11.md](../../utils/XIOS/build_xios_r2528_archer2_gcc11.md).  


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work
NEMO_LABEL=nemo
NEMO_VERSION=4.2.0
NEMO_NAME=${NEMO_LABEL}-${NEMO_VERSION}
NEMO_ROOT=${PRFX}/${NEMO_LABEL}
NEMO_MAKE=${NEMO_ROOT}/${NEMO_NAME}
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.


Download the NEMO source
------------------------

```bash
mkdir -p ${NEMO_ROOT}
cd ${NEMO_ROOT}

wget https://forge.nemo-ocean.eu/${NEMO_LABEL}/${NEMO_LABEL}/-/archive/${NEMO_VERSION}/${NEMO_NAME}.tar.gz
tar -xvzf ${NEMO_NAME}.tar.gz
rm ${NEMO_NAME}.tar.gz
cd ${NEMO_NAME}
```


Copy the NEMO arch file
-----------------------

Copy the [./arch-X86_ARCHER2-gcc.fcm](./arch-X86_ARCHER2-gcc.fcm) file to the `./arch` folder.


Edit the config and arch files
------------------------------

Edit line 480 of `./ext/FCM/lib/Fcm/Config.pm`:

```bash
change "FC_MODSEARCH => ''," to "FC_MODSEARCH => '-J',"
```

Next, replace `</path/to/XIOS>` in `./arch/arch-X86_ARCHER2-gcc.fcm` with the appropriate path.

We are now ready to build a NEMO configuration.


Setup the module environment
----------------------------

```bash
module -q load PrgEnv-gnu
module -q load cray-hdf5-parallel
module -q load cray-netcdf-hdf5parallel
```


Build a NEMO configuration
--------------------------

Various NEMO configurations can be found in the `./cfgs` folder.` The example below,
builds the `GYRE_PISCES` config.

```bash
cd ${NEMO_MAKE}

NEMO_CONFIG=GYRE_PISCES

./makenemo -n ${NEMO_CONFIG}_GCC11 -r ${NEMO_CONFIG} -m X86_ARCHER2-gcc -j 16
```


Setting up a test configuration
-------------------------------

```bash
cd ${NEMO_MAKE}/cfgs/${NEMO_CONFIG}_GCC11/EXP00

rm -rf nemo
cp ${NEMO_MAKE}/cfgs/${NEMO_CONFIG}_GCC11/BLD/bin/nemo.exe ./nemo
ln -s </path/to/xios_server.exe> xios_server.exe
```

See the following links for example submission scripts.

[./submit-nemo-gcc-ofi.ll](./submit-nemo-gcc-ofi.ll)
[./submit-nemo-gcc-ucx.ll](./submit-nemo-gcc-ucx.ll)

Please copy one of these to the `EXPOO` folder, edit as necessary and then submit
your job from that location using `sbatch`.
