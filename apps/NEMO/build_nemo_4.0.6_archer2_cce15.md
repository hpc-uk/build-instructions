Instructions for building NEMO 4.0.6 on ARCHER2
===============================================

These instructions are for building NEMO 4.0.6 on the ARCHER2 full system (HPE Cray EX, AMD Zen2 7742) using CCE 15.

We assume that the user has access to XIOS 2.5. Instructions for building XIOS 2.5 can be found at [../../utils/XIOS/build_xios_2.5_archer2_cce15.md](../../utils/XIOS/build_xios_2.5_archer2_cce15.md).  


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


Checkout the NEMO source
------------------------

```bash
mkdir -p ${NEMO_ROOT}
cd ${NEMO_ROOT}

svn co https://forge.ipsl.jussieu.fr/${NEMO_LABEL}/svn/${NEMO_LABEL^^}/releases/r${NEMO_VERSION:0:3}/r${NEMO_VERSION} ${NEMO_NAME}

cd ${NEMO_NAME}
```


Copy the NEMO arch file
-----------------------

Copy the [./arch-X86_ARCHER2-cce.fcm](./arch-X86_ARCHER2-cce.fcm) file to the `./arch` folder.


Edit the config and arch files
------------------------------

Edit line 480 of `./ext/FCM/lib/Fcm/Config.pm`:

```bash
change "FC_MODSEARCH => ''," to "FC_MODSEARCH => '-J',"
```

Next, replace `</path/to/XIOS>` in `./arch/arch-X86_ARCHER2-cce.fcm` with the appropriate path.

We are now ready to build a NEMO configuration.


Setup the module environment
----------------------------

```bash
module -q load PrgEnv-cray
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

./makenemo -n ${NEMO_CONFIG}_CCE15 -r ${NEMO_CONFIG} -m X86_ARCHER2-cce -j 16
```


Setting up a test configuration
-------------------------------

```bash
cd ${NEMO_MAKE}/cfgs/${NEMO_CONFIG}_CCE15/EXP00

rm -rf nemo
cp ${NEMO_MAKE}/cfgs/${NEMO_CONFIG}_CCE15/BLD/bin/nemo.exe ./nemo
ln -s </path/to/xios_server.exe> xios_server.exe
```

See the following links for example submission scripts.

[./submit-nemo-cce-ofi.ll](./submit-nemo-cce-ofi.ll)
[./submit-nemo-cce-ucx.ll](./submit-nemo-cce-ucx.ll)

Please copy one of these to the `EXPOO` folder, edit as necessary and then submit
your job from that location using `sbatch`.
