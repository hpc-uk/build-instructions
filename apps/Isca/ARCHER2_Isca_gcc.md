# Isca on ARCHER2

## Load modules and set python environment 

```
module restore /etc/cray-pe.d/PrgEnv-gnu
module load cray-python 
module swap gcc gcc/9.3.0 

export PYTHONUSERBASE=/work/group/group/username/.local
export PATH=$PYTHONUSERBASE/bin:$PATH
export PYTHONPATH=$PYTHONUSERBASE/lib/python3.8/site-packages:$PYTHONPATH
```

## Download Isca and install python module 

```
cd /work/group/group/username 
mkdir Isca 
cd Isca 
git clone https://github.com/ExeClim/Isca 
cd Isca/src/extra/python/ 
pip install -r requirements.txt 
pip install --user -e . 
```

## Set up environment for building and running 

Create the following file for the archer2 environment (named archer2) at `/src/extra/env/` 
```
echo loadmodules for archer2 

module load cray-hdf5 
module load cray-netcdf 

export GFDL_MKMF_TEMPLATE=gfort 

export F90=ftn 
export CC=cc 

```

Set the following environment variables for example like so, based on where Isca is in your work directory above. (You can add these to your ./bashrc so that they are set when you log in). 

```
# directory of the Isca source code 
export GFDL_BASE=/work/group/group/username/Isca/Isca 
# "environment" configuration for archer2 
export GFDL_ENV=archer2 
# temporary working directory used in running the model 
export GFDL_WORK=/work/group/group/username/Isca/gfdl_work 
# directory for storing model output 
export GFDL_DATA=/work/group/group/username/Isca/gfdl_data 
```

Edit the `run.sh` template file in `src/extra/python/isca/templates/run.sh`

On line 22 change `-np` to `-n` and all instances of `mpirun` to `srun`

## Build and run Isca 

First launch an interactive job 

```
srun --nodes=1 --exclusive --time=00:20:00 \ 
--partition=standard --qos=short --reservation=shortqos \ 
--pty /bin/bash 
```
```
cd $GFDL_BASE/exp/test_cases/held_suarez 
python3 held_suarez_test_case.py 
```

## Example job script for running Isca

```
#!/bin/bash 
#SBATCH --job-name=Isca
#SBATCH --time=00:20:00 
#SBATCH --nodes=1 
#SBATCH --tasks-per-node=128 
#SBATCH --cpus-per-task=1 
#SBATCH --account= [accountname] 
#SBATCH --partition=standard 
#SBATCH --qos=short 
#SBATCH --reservation=shortqos 


module restore /etc/cray-pe.d/PrgEnv-gnu
module load cray-python 
module swap gcc gcc/9.3.0

export PYTHONUSERBASE=/work/group/group/username/.local
export PATH=$PYTHONUSERBASE/bin:$PATH
export PYTHONPATH=$PYTHONUSERBASE/lib/python3.8/site-packages:$PYTHONPATH

export GFDL_BASE=/work/group/group/username/Isca/Isca 
export GFDL_ENV=archer2 
export GFDL_WORK=/work/group/group/username/Isca/gfdl_work 
export GFDL_DATA=/work/group/group/username/Isca/gfdl_data 

cd $GFDL_BASE/exp/test_cases/held_suarez/ 
python held_suarez_test_case.py 
```

Note that the number of cores Isca actually uses is set by the `NCORES` parameter in the python script. The model requires there to be a minimum of 2 latitude bands per core, so at the default T42 resolution (128 lon x 64 lat) the maximum number of cores you can use is `64/2=32`. 
