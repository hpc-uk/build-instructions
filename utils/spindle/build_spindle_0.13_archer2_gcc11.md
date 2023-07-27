Instructions for building Spindle 0.13 on ARCHER2
=================================================

These instructions are for building Spindle 0.13 on the ARCHER2 full system (HPE Cray EX, AMD Zen2 7742).


Setup initial environment
-------------------------

```bash
PRFX=${HOME/home/work}/tools

SPINDLE_LABEL=spindle
SPINDLE_VERSION=0.13
SPINDLE_NAME=${SPINDLE_LABEL}-${SPINDLE_VERSION}
SPINDLE_ROOT=${PRFX}/${SPINDLE_LABEL}
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.


Download source code
--------------------

```bash
mkdir -p ${SPINDLE_ROOT}
cd ${SPINDLE_ROOT}

wget https://github.com/hpc/${SPINDLE_LABEL^}/archive/refs/tags/v${SPINDLE_VERSION}.tar.gz

tar -xvzf v${SPINDLE_VERSION}.tar.gz
rm v${SPINDLE_VERSION}.tar.gz

mv ${SPINDLE_LABEL^}-${SPINDLE_VERSION} ${SPINDLE_NAME}
```


Build Spindle
-------------

```bash
cd ${SPINDLE_ROOT}/${SPINDLE_NAME}

module -q restore
module -q load PrgEnv-gnu
module -q load cray-python

./configure CC=gcc CXX=g++ \
    --enable-sec-none \
    --with-slurm-launch \
    --with-localstorage=/dev/shm \
    --with-python-prefix=/opt/cray/pe/python/${CRAY_PYTHON_LEVEL} \
    --prefix=${SPINDLE_ROOT}/${SPINDLE_VERSION}

make -j 8
make -j 8 install
make distclean
```

The following link explains the most important `configure` options.

[https://github.com/hpc/Spindle/blob/devel/INSTALL](https://github.com/hpc/Spindle/blob/devel/INSTALL)

Note, the security model is set to none (`--enable-sec-none`) because, at runtime, Spindle will be confined to
the compute nodes and is thus running within a secure environment (i.e., the Slurm job submission itself runs
on a compute node).

ARCHER2 is setup such that a password is required when running ‘rsh <nodename>’ or ‘ssh <nodename>’ to access the nodes
assigned to a job, otherwise the Spindle build could be configured with the ‘--with-rsh-launch’ option, which instructs
Spindle to start its daemons by rsh/ssh’ing to each node.

The workaround is to instead use the `--with-slurm-launch` option &mdash; that causes Spindle to launch daemons by running
a `srun ... spindlebe` command.

However, there is an issue with Slurm integration. This becomes apparent when the `--with-rm=slurm` configure option is
used as this results in the following error message.

*Slurm support was requested, but slurm 22.05.8, which is later than 20.11, was detected.
This version of slurm breaks spindle daemon launch. You can disable this error message
and build spindle with slurm-based daemon launching anyways by explicitly passing the
`--with-slurm-launch` option (you might still be able to get spindle to work by running jobs
with srun's `--overlap` option). Or you could switch to having spindle launch daemons with
rsh/ssh by passing the `--with-rsh-launch` option, and ensuring that rsh/ssh to nodes works
on your cluster.*

And this is why `--with-slurm-launch` is used in the configure command shown above and why the `srun --overlap` option
must always be used when running codes with Spindle.


Setup Spindle environment file
------------------------------

Create a Bash environment file that when sourced will put the Spindle executable and
libraries on the appropriate paths.

```bash
SPINDLE_ENV_FILE=${SPINDLE_ROOT}/${SPINDLE_VERSION}/env.sh

echo -e "SPINDLE_ROOT=${SPINDLE_ROOT}/${SPINDLE_VERSION}\n" > ${SPINDLE_ENV_FILE}

echo -e "export PATH=\${SPINDLE_ROOT}/bin:\${PATH}" >> ${SPINDLE_ENV_FILE}
echo -e "export CPATH=\${SPINDLE_ROOT}/include:\${CPATH}" >> ${SPINDLE_ENV_FILE}
echo -e "export MANPATH=\${SPINDLE_ROOT}/share/man:\${MANPATH}" >> ${SPINDLE_ENV_FILE}
echo -e "export LD_LIBRARY_PATH=\${SPINDLE_ROOT}/lib:\${LD_LIBRARY_PATH}" >> ${SPINDLE_ENV_FILE}
echo -e "export LD_LIBRARY_PATH=\${SPINDLE_ROOT}/lib/spindle:\${LD_LIBRARY_PATH}" >> ${SPINDLE_ENV_FILE}
```


Test Spindle
------------

Test the Spindle install by submitting the following script.

```bash
#!/bin/bash --login

#SBATCH --job-name=tmimport
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:20:00
#SBATCH --account=<budget code>
#SBATCH --partition=standard
#SBATCH --qos=short

source ${HOME/home/work}/tools/spindle/0.13/env.sh

export SRUN_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK}

spindle --slurm \
    srun --overlap --distribution=block:block --hint=nomultithread --unbuffered \
        /bin/cat /proc/self/maps
```

The resulting Slurm output file should contain some lines that have the word `spindle`.

```bash
/dev/shm/spindle.88948/work/z19/z19/mrb23cab/tools/spindle/0.13/lib/spindle/0-spindlens-file-libspindle_audit_pipe.so
...
/dev/shm/spindle.88948/usr/bin/1-spindlens-file-cat
```
