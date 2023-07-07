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

XIOS_DIR-/path/to/xios
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.
This also applies to the `XIOS_DIR` path, which must point to a build of XIOS 2.5.


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

Various NEMO configurations can be found in the `./cfgs` folder. The example below,
builds the [GYRE_PISCES](https://forge.ipsl.jussieu.fr/nemo/chrome/site/doc/NEMO/guide/html/cfgs.html#gyre-pisces) config.

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
ln -s ${XIOS_DIR}/bin/xios_server.exe xios_server.exe
```

See the following links for example submission scripts.

[./submit-cce-ofi.ll](./submit-cce-ofi.ll)\
[./submit-cce-ucx.ll](./submit-cce-ucx.ll)

Please copy one of these to the `EXPOO` folder, edit as necessary and then submit
your job from that location using `sbatch`.


Adjusting NEMO parameters
-------------------------

The NEMO input parameters can be found in the `namelist_cfg` file. Parameters such
as `nn_itend` control how many time steps will be covered by the simulation.

There are two key parameters that need to be adjusted together, namely, `nn_GYRE`
and `rn_rdt`. The former is the resolution - its default value is `1 degree`.
The latter is the time step size in seconds - set to `7200 s` if `nn_GYRE=1`.

Another parameter of interest is `nn_stock`, which controls how frequently restart
files are written during the simulation. You can set this parameter to `-1` to turn
off completely the writing of restart files.
