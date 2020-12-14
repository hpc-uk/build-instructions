```bash
PRFX=/lustre/sw
MPI4PY_LABEL=mpi4py
MPI4PY_VERSION=3.1.0
MPI4PY_NAME=${MPI4PY_LABEL}-${MPI4PY_VERSION}

mkdir -p ${PRFX}/${MPI4PY_LABEL}
cd ${PRFX}/${MPI4PY_LABEL}

git clone https://bitbucket.org/${MPI4PY_LABEL}/${MPI4PY_LABEL}.git
mv ${MPI4PY_LABEL} ${MPI4PY_NAME}
cd ${MPI4PY_NAME}

module load anaconda/python3
module load intel-compilers-19/19.0.0.117
module load mpt/2.22

```

