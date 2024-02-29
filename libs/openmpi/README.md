OpenMPI
=======

This folder contains instructions for building OpenMPI libraries on UK HPC systems.

The Open MPI Project is an open source Message Passing Interface implementation that is
developed and maintained by a consortium of academic, research, and industry partners.

See the [OpenMPI home page](https://www.open-mpi.org/).

History
-------

 Date | Person | System | Version | Notes
 ---- | ------ | ------ | ------- | -----
 2023-06-12 | Michael Bareford | ARCHER2 | 4.1.5 | GCC 11.2.0
 2022-09-28 | Michael Bareford | ARCHER2 | 4.1.4 | GCC 11.2.0
 2024-02-14 | Michael Bareford | Cirrus | 4.1.6 | GCC 10.2.0
 2024-06-02 | Luca Parisi | Cirrus | 5.0.0 | GCC 10.2.0

Build Instructions
------------------

* [OpenMPI 4.1.5 ARCHER2 Build Instructions (GCC 11)](build_openmpi_4.1.5_archer2_gcc11.md)
* [OpenMPI 4.1.4 ARCHER2 Build Instructions (GCC 11)](build_openmpi_4.1.4_archer2_gcc11.md)
* [OpenMPI 4.1.6 Cirrus Build Instructions (GCC 10)](build_openmpi_4.1.6_cirrus_gcc10.md)
* [OpenMPI 5.0.0 Cirrus Build Instructions (GCC 10)](build_openmpi_5.0.0_cirrus_gcc10.md)


Notes
-----

When running on ARCHER2, please ensure that you set `export OMPI_MCA_btl='^openib'` before launching
your OpenMPI-linked code via srun/mpirun. This disables the OpenIB byte transfer layer.
