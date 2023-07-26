Instructions for running ERT 1.1.0 on ARCHER2
=============================================

These instructions are for running the Empirical Roofline Tool 1.1.0 on the ARCHER2 full system (HPE Cray EX, AMD Zen2 7742).
You must of first installed ERT, see [./build_ert_1.1.0_archer2.md](./build_ert_1.1.0_archer2.md).

You should have already cloned the [Berkeley Lab CS Roofline Toolkit](https://bitbucket.org/berkeleylab/cs-roofline-toolkit/src/master/) to a location on `/work`.
Having done so, please move to the `Empirical_Roofline_Tool-1.1.0` folder.


Create submission script
------------------------

Create a Slurm submission script, `submit.ll`, as shown below.

```bash
#!/bin/bash --login

#SBATCH --job-name=ert
#SBATCH -o /dev/null
#SBATCH -e /dev/null
#SBATCH --nodes=1
#SBATCH --time=01:00:00
#SBATCH --account=<budget code>
#SBATCH --partition=standard
#SBATCH --qos=standard


module -q restore
module -q load PrgEnv-gnu

module -q load cray-python
module -q load gnuplot


ERT_PLATFORM=archer2.epcc.ed.ac.uk
ERT_EXE_FILE=${SLURM_SUBMIT_DIR}/ert
ERT_CFG_FILE=${SLURM_SUBMIT_DIR}/Config/config.${ERT_PLATFORM}
ERT_RES_PATH=${SLURM_SUBMIT_DIR}/Results.${ERT_PLATFORM}
ERT_ARC_PATH=${SLURM_SUBMIT_DIR}/arc/Results.${ERT_PLATFORM}/${SLURM_JOB_ID}

rm -rf ${ERT_RES_PATH}
mkdir -p ${ERT_RES_PATH}

mkdir -p ${ERT_ARC_PATH}


${ERT_EXE_FILE} --verbose=2 --build-only ${ERT_CFG_FILE} &> ${ERT_ARC_PATH}/1-build.out
${ERT_EXE_FILE} --verbose=2 --run-only ${ERT_CFG_FILE} &> ${ERT_ARC_PATH}/2-run.out
${ERT_EXE_FILE} --verbose=2 --post-only --gnuplot ${ERT_CFG_FILE} &> ${ERT_ARC_PATH}/3-plot.out


mv ${ERT_RES_PATH}/* ${ERT_ARC_PATH}/
rmdir ${ERT_RES_PATH}
```


Submit ERT job
--------------

```bash
sbatch submit.ll
```

The job script specified above will build then run the ERT kernels, collecting performance data.
The last step generates plots (including the roofline) from the data.


View the roofline
-----------------

You can view the roofline plot on an ARCHER2 login node by first loading a suitable `imagemagick` module.

```bash
module load imagemagick/6.8.9
```

The imagemagick `display` command is used to view the roofline.

```bash
display -rotate 90 -background white -flatten "/path/to/roofline.ps"
```

You may find that the various roofline labels for the L1,2,3 caches and DRAM are a little aschew.
You can correct this manually by editing the `roofline.ps` postscript file. For example, you can
look for the line preceding the `L1` label and change `45 rotate` to `55 rotate`. You can also
alter the height of a label by adjusting the number that comes immediately after the `rotate`
keyword.
