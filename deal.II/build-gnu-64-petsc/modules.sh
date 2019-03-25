# required modules
# need more recent MPICH to support parallel HDF5
module swap cray-mpich cray-mpich/7.3.2
# using intel compilers
module swap PrgEnv-cray PrgEnv-gnu/5.2.56

module load cmake/3.5.2 \
       boost-serial/1.60

# optional modules
# (tpsl includes metis)
module load cray-hdf5-parallel/1.10.0.1 \
       cray-tpsl-64/16.12.1 \
       cray-petsc-64/3.6.3.0 
