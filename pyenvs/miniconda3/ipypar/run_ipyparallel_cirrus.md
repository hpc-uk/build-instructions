Instructions for running an ipyparallel session on Cirrus
=========================================================

The Slurm submission script below requests a GPU node and loads the machine learning
specific Miniconda3 module before starting the ipyparallel cluster and Jupyter notebook.
This script is suitable therefore for running pytorch commands interactively on a Cirrus
GPU node. Obviously, the script may need to be altered to suit a different use case. 

Login to your Cirrus account and submit the Slurm script shown below.


Submit `sbatch submit_ipypar.ll`
--------------------------------

```bash
#!/bin/bash

#SBATCH --job-name=ipypar
#SBATCH --time=00:20:00
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --partition=gpu-cascade
#SBATCH --qos=gpu
#SBATCH --gres=gpu:1
#SBATCH --account=<account_code>


# setup termination handler
function stop_jupyter {
    action=$([ $1 -lt 0 ] && echo "terminating" || echo "stopping")
    echo `date` ": ${action} jupyter notebook..."
    if pgrep jupyter; then
        kill $(pgrep jupyter)
        sleep 5s
    fi
}

function stop_engines {
    action=$([ $1 -lt 0 ] && echo "terminating" || echo "stopping")
    echo `date` ": ${action} ipyparallel engines..."
    IPCLUSTER_STOP_OUTPUT=ipcluster_stop.out
    ipcluster stop --profile=mpi &> $IPCLUSTER_STOP_OUTPUT &
    sleep 5s
}

function term_processes {
    stop_jupyter -1
    stop_engines -1
    exit -1
}

trap 'term_processes' TERM
trap 'term_processes' SIGUSR1


export nodecnt=${SLURM_JOB_NUM_NODES}
export corecnt=`expr ${nodecnt} \* ${SLURM_CPUS_ON_NODE}`
export enginecnt=`expr ${corecnt} - 1`

export SLURM_NTASKS=${corecnt}
export SLURM_NTASKS_PER_NODE=`expr ${SLURM_NTASKS} \/ ${SLURM_JOB_NUM_NODES}`
export SLURM_TASKS_PER_NODE="${SLURM_NTASKS_PER_NODE}(x${SLURM_JOB_NUM_NODES})"


cd ${SLURM_SUBMIT_DIR}

rm -f ipcluster_start.out
rm -f ipcluster_stop.out
rm -f jupyter_start.out

# load modules
module use /lustre/sw/modulefiles.dev
module load miniconda3/4.9.2-py38-ml

export OMPI_MCA_mca_base_component_show_load_errors=0
export OMPI_MCA_pml=ob1
export OMPI_MCA_warn_on_fork=0

# create the ipyparallel mpi profile
ipython profile create --parallel --profile=mpi

# start mpi engines
IPCLUSTER_START_OUTPUT="ipcluster_start.out"
ipcluster start --debug --profile=mpi -n ${enginecnt} &> ${IPCLUSTER_START_OUTPUT} &

sleepn=0
while [ : ]; do
    if [ -f "${IPCLUSTER_START_OUTPUT}" ]; then
        if grep -q "Engines appear to have started successfully" ${IPCLUSTER_START_OUTPUT}; then
            break
        fi
    fi
    if [ $sleepn -lt 10 ]; then
        sleep 10s
    else
        stop_engines -1
        exit -1
    fi
    sleepn=$((sleepn+1))
done

# start jupyter notebook
JUPYTER_START_OUTPUT="jupyter_start.out"
jupyter notebook --no-browser --port=19888 --ip=0.0.0.0 &> ${JUPYTER_START_OUTPUT} &


# sleep until around 5 minutes before end of walltime
walltime=`squeue -h -j ${SLURM_JOBID} -o "%l"`
wtlen=${#walltime}

if [ ${wtlen} -eq 5 ]; then
    mn=`echo ${walltime} | cut -d':' -f 1`
    waittime=$((mn - 5))
else
    hr=`echo ${walltime} | cut -d':' -f 1`
    mn=`echo ${walltime} | cut -d':' -f 2`
    waittime=$((hr*60 + mn - 5))
fi

if [ $waittime -gt 0 ]; then
    sleep ${waittime}m
fi


stop_jupyter 0
stop_engines 0
exit 0
```


Once the job is running, execute `sacct -j <jobid> --format=NodeList%32` with the returned job number
and from the `sacct` output extract the name of the first node assigned to the job.

Now start a second Cirrus login session using the ssh command given below.

```bash
ssh <username>@cirrus.epcc.ed.ac.uk -L19888:<nodename>:19888
```


You can now launch a browser on your local machine and begin running your remote Jupyter notebook session, just click [http://localhost:19888](http://localhost:19888).
Please note, you may not get a login prompt immediately as it takes a minute or two for the Jupyter session to get started (check for the
presence of a `ipcluster_start.out` file within your first Cirrus session). If you do get a login prompt enter the password specified when
setting up the ipyparallel config and you should be presented with a file explorer style interface for your Cirrus account.

Some example jupyter notebooks (`*.ipynb` files) along with supporting python scripts can be found in `/lustre/home/shared/y15/jupyter`.
The simplest of these is `ipyparallel-mpi.ipynb`: the notebook uses the `psum.py` script to perform the same summation on all available cores.
A more interesting example is the `parallelpi.ipynb` notebook, which uses the functions defined in `pydigits.py` and the matplotlib package to
visualise how frequently digit pairs (00 - 99) occur within the first billion digits of PI. More information concerning this example can be found
at [https://ipyparallel.readthedocs.io/en/latest/demos.html](https://ipyparallel.readthedocs.io/en/latest/demos.html).

When you have finished with your ipyparallel-enabled Jupyter notebook, simply logout then return to your first Cirrus session and run `scancel -b -s SIGUSR1 <jobid>` with the
original Slurm job number. This will ensure that all the ipyparallel and Jupyter processes are explicitly shutdown. Finally, the second Cirrus session
can be shutdown with a simple `exit` command.
