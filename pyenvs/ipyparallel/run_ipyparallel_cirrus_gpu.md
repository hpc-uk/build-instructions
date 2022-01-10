Instructions for running an ipyparallel session on Cirrus (GPU)
===============================================================

The Slurm submission script below requests a GPU node and loads the mpi4py Miniconda3 module, `mpi4py/3.1.3-ompi-gpu`,
before starting the ipyparallel cluster and Jupyter notebook. This script is suitable therefore for running pytorch commands
interactively on a Cirrus GPU node. Obviously, the script may need to be altered to suit a different use case. 

Login to your Cirrus account and submit the Slurm script shown below.


Submit `sbatch submit_ipypar.ll`
--------------------------------

```bash
#!/bin/bash

#SBATCH --job-name=ipypar
#SBATCH --time=01:00:00
#SBATCH --signal=B:TERM@60
#SBATCH --nodes=1
#SBATCH --partition=gpu-cascade
#SBATCH --qos=gpu
#SBATCH --gres=gpu:1
#SBATCH --account=<account_code>


IPCLUSTER_START_OUTPUT="ipcluster_start.out"
IPCLUSTER_STOP_OUTPUT="ipcluster_stop.out"
JUPYTER_OUTPUT="jupyter.out"


# setup termination handler
function stop_jupyter {
    action=$([ $1 -lt 0 ] && echo "terminating" || echo "stopping")
    echo `date` ": ${action} jupyter notebook..."
    if pgrep jupyter; then
        kill $(pgrep jupyter)
        sleep 5s
    fi
    echo "Done."
}

function stop_engines {
    action=$([ $1 -lt 0 ] && echo "terminating" || echo "stopping")
    echo `date` ": ${action} ipyparallel engines..."
    ipcluster stop --profile=mpi &> ${IPCLUSTER_STOP_OUTPUT} &
    sleep 5s
    echo "Done."
}

function terminate_processes {
    stop_jupyter 0
    stop_engines 0
    exit 0
}

trap 'terminate_processes' TERM


export nodecnt=${SLURM_NNODES}
export corecnt=`expr ${nodecnt} \* ${SLURM_CPUS_ON_NODE}`
export enginecnt=`expr ${corecnt} - 1`

export SLURM_NTASKS=${corecnt}
export SLURM_NTASKS_PER_NODE=`expr ${SLURM_NTASKS} \/ ${SLURM_NNODES}`
export SLURM_TASKS_PER_NODE="${SLURM_NTASKS_PER_NODE}(x${SLURM_NNODES})"


cd ${SLURM_SUBMIT_DIR}

rm -f ${IPCLUSTER_START_OUTPUT}
rm -f ${IPCLUSTER_STOP_OUTPUT}
rm -f ${JUPYTER_OUTPUT}


# load module(s)
module use /lustre/sw/modulefiles.miniconda3
module load mpi4py/3.1.3-ompi-gpu


export OMPI_MCA_mca_base_component_show_load_errors=0
export OMPI_MCA_pml=ob1
export OMPI_MCA_mpi_warn_on_fork=0


# start mpi engines
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
jupyter notebook --no-browser --notebook-dir /lustre/home --port=19888 --ip=0.0.0.0 &> ${JUPYTER_OUTPUT} &


wait
```


Once the job is running, execute `sacct -j <jobid> --format=NodeList%32` with the returned job number
and from the `sacct` output extract the name of the first node assigned to the job.

Now start a second Cirrus login session using the ssh command given below.

```bash
ssh <username>@cirrus.epcc.ed.ac.uk -L19888:<nodename>:19888
```


You can now launch a browser on your local machine and begin running your remote Jupyter notebook session, just click [http://localhost:19888](http://localhost:19888).
Please note, you may not get a login prompt immediately as it takes a minute or two for the Jupyter session to get started (check for the
presence of a non-empty `jupyter.out` file within your first Cirrus session). Once you do get a Jupyter login prompt, enter the password specified when
setting up the ipyparallel config and you should be presented with a file explorer style interface for your Cirrus account.

Some example Jupyter notebooks (`*.ipynb` files) along with supporting python scripts can be found in `/lustre/home/shared/y15/jupyter`.
The simplest of these is `ipyparallel-mpi.ipynb`: the notebook uses the `psum.py` script to perform the same summation on all available cores.
A more interesting example is the `parallelpi.ipynb` notebook, which uses the functions defined in `pydigits.py` and the matplotlib package to
visualise how frequently digit pairs (00 - 99) occur within the first billion digits of PI. More information concerning this example can be found
at [https://ipyparallel.readthedocs.io/en/latest/demos.html](https://ipyparallel.readthedocs.io/en/latest/demos.html).

When you have finished with your ipyparallel-enabled Jupyter notebook, simply logout then return to your first Cirrus session and run `scancel -b --signal=TERM <jobid>`
with the original Slurm job number. This will ensure that all the ipyparallel and Jupyter processes are explicitly shutdown. If you do not call scancel the processes will
instead be shutdown automatically, 60 seconds before the scheduled end time (see the signal directive in `submit_ipypar.ll`). Finally, the second Cirrus session can be
shutdown with a simple `exit` command.