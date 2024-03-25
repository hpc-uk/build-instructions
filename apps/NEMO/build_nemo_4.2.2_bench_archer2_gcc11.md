Instructions for building NEMO 4.2.2 on ARCHER2 for BENCH test
==============================================================

These instructions are for building NEMO 4.2.2 on ARCHER2 (HPE Cray EX, AMD Zen2 7742) using GCC 11, specifically for the BENCH test.

The BENCH test allows you to run any NEMO configuration (including ORCA type or BDY) with idealized grid and initial state: NEMO does not need any input
file other than the namelists. Three examples of "namelist_cfg" are provided that correspond to  ORCA1, OR025 and ORCA12 grid configurations.
An extensive description of BENCH is available at [https://gmd.copernicus.org/articles/15/1567/2022/](https://gmd.copernicus.org/articles/15/1567/2022/).

We assume that the user has access to XIOS trunk revision 2615.
Instructions for building XIOS r2615 are similar to those found at [../../utils/XIOS/build_xios_r2528_archer2_gcc11.md](../../utils/XIOS/build_xios_r2528_archer2_gcc11.md).
Although the BENCH test does not use XIOS by default, the `arch-X86_ARCHER2-gcc.fcm` build script mentioned below is setup to use XIOS if required.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work
NEMO_LABEL=nemo
NEMO_VERSION=4.2.2
NEMO_NAME=${NEMO_LABEL}-${NEMO_VERSION}
NEMO_ROOT=${PRFX}/${NEMO_LABEL}
NEMO_MAKE=${NEMO_ROOT}/${NEMO_NAME}

export XIOS_DIR=/path/to/xios
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.
This also applies to the `XIOS_DIR` path, which must point to a trunk build of XIOS.


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

We are now ready to build a NEMO configuration.


Setup the module environment
----------------------------

```bash
module -q load PrgEnv-gnu
module -q load cray-hdf5-parallel
module -q load cray-netcdf-hdf5parallel
```


Build a NEMO BENCH test
-----------------------

```bash
cd ${NEMO_MAKE}

NEMO_TEST=BENCH

./makenemo -n ${NEMO_TEST}_GCC11 -a ${NEMO_TEST} -m X86_ARCHER2-gcc -j 16
```

Once the build starts, you should see the following message.

```bash
You are installing a new configuration BENCH_GCC11 from BENCH with sub-components:  OCE ICE TOP
```

OCE (*blue ocean*) is the physical ocean component of NEMO. It is a primitive equation model adapted to simulate regional
and global ocean circulation up to kilometric scales. The prognostic variables are the three-dimensional velocity field,
linear or non-linear sea surface height, temperature and salinity.

The ICE (*white ocean*) component represents sea ice, covering ice dynamics, thermodynamics, brine inclusions and subgrid-scale thickness variations.

TOP (*green ocean*) stands for Tracers in the Ocean Paradigm. This component handles oceanic passive tracers. It provides the physical constraints
and boundary conditions for oceanic tracers transport and represents a generalized, hardwired interface toward biogeochemical models to enable a seamless coupling.
The TOP component includes a built-in biogeochemical model (called PISCES) to simulate lower trophic levels ecosystem dynamics in the global ocean.
(PISCES stands for Pelagic Interactions Scheme for Carbon and Ecosystem Studies.)


Setting up a test configuration
-------------------------------

From the test submission folder, choose a grid resolution for `namelist_cfg`.

ORCA1 has 1 degree horizontal resolution and 75 vertical levels for 7.9 million grid points in total.
ORCA025 has 1/4 deg. hoz. res. and 75 vert. lev. (110.4 million points).
ORCA12 has 1/12 deg. hoz. res. and 75 vert. lev. (991.6 million points).

We select below the coarsest resolution.

```bash
cd ${NEMO_MAKE}/tests/${NEMO_TEST}_GCC11/EXP00

cp namelist_cfg_orca1_like namelist_cfg
```

The `namelist_cfg` file contain various parameters. Notice that `nn_stock` and `nn_write` are set to `-1` so as
to switch off simulation output. The `nn_itend` option controls the number of time steps. Please set this
to `10` in order to confirm quickly that the NEMO job runs correctly. The time step size in seconds is given
by the `rn_Dt=3600` parameter. Therefore 10 time steps is equivalent to a simulation time of 10 hours.

Below is an example submission script for launching the NEMO BENCH test.

```bash
#!/bin/bash

#SBATCH --job-name=nemo
#SBATCH --time=00:20:00
#SBATCH --account=<budget code>
#SBATCH --partition=standard
#SBATCH --qos=short
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=128
#SBATCH --cpus-per-task=1

cat $0

module -q load PrgEnv-gnu
module -q load cray-hdf5-parallel
module -q load cray-netcdf-hdf5parallel

export OMP_NUM_THREADS=1
export SRUN_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK}

srun --distribution=block:block --hint=nomultithread --cpu-freq=2000000 ./nemo

RESULTS_DIR=${SLURM_SUBMIT_DIR}/results/${SLURM_JOB_ID}
mkdir -p ${RESULTS_DIR}
rm ${SLURM_SUBMIT_DIR}/*.nc
cp ./namelist_cfg ${RESULTS_DIR}/
cp ./namelist_ice_cfg ${RESULTS_DIR}/
cp ./namelist_pisces_cfg ${RESULTS_DIR}/
cp ./namelist_top_cfg ${RESULTS_DIR}/
mv ${SLURM_SUBMIT_DIR}/communication_report.txt ${RESULTS_DIR}/
mv ${SLURM_SUBMIT_DIR}/layout.dat ${RESULTS_DIR}/
mv ${SLURM_SUBMIT_DIR}/ocean.output ${RESULTS_DIR}/
mv ${SLURM_SUBMIT_DIR}/output.namelist.* ${RESULTS_DIR}/
mv ${SLURM_SUBMIT_DIR}/run.stat ${RESULTS_DIR}/
mv ${SLURM_SUBMIT_DIR}/slurm-${SLURM_JOB_ID}.out ${RESULTS_DIR}/slurm.out
mv ${SLURM_SUBMIT_DIR}/time.step ${RESULTS_DIR}/
```

Running at higher resolutions (e.g., ORCA025 and ORCA12) requires more nodes
to avoid OOM errors and an adjusted number of tasks per node to allow distribution
of the workload.

For ORCA025, you need 2 nodes with 126 tasks per node. ORCA12 can be run with the same
number of MPI ranks per node, but requires at least 16 nodes.

If you wish to run with all 128 cores per node, you can set the `jpni` and `jpnj` parameters
specified in the `namelist_cfg` file such that the product (`jpni` $\times$ `jpnj`) is equal to the
total number of cores.

The default BENCH configuration does require substantial memory bandwidth. This can be
mitigated however by deactiving the PISCES component and instead running with just an
age tracer, which tracks the time-dependent spread of surface waters into the ocean interior.
NEMO can be configured in this way by setting two parameters in the `namelist_top_cfg` file,
see below.

```bash
ln_pisces = .false.
ln_age = .true.
```
