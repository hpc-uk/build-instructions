CPL-OpenFOAM-LAMMPS
===================
This folder contains files and documentation for building and maintaining CPL-OpenFOAM-LAMMPS on Archer2

History
-------

Date | Person | System | Version | Notes
---- | -------|--------|---------|------
2023-07-13 | Gavin Pringle | ARCHER2 | 13Jul2023 | Build instructions for rebuilt ARCHER2 using GCC 10.2.0 compilers
2023-01-30 | Gavin Pringle | ARCHER2 | 30Jan2023 | Build instructions for ARCHER2 using GCC 10.2.0 compilers
2023-02-20 | Gavin Pringle | ARCHER2 | 20Feb2023 | Run instructions for CPLTestSocketFoam on ARCHER2
2023-13-13 | Gavin Pringle | ARCHER2 | 13Mar2023 | Updated CPLTestSocketFoam run instructions
2023-05-29 | Gavin Pringle | ARCHER2 | 29May2023 | Run instructions for Couette_coupled/Partial_overlap on ARCHER2

Build Instructions
------------------

* [CPL-OpenFOAM-LAMMPS 13JUl2023 ARCHER2 Build Instructions (GCC 10.2.0)](build_cpl-openfoam-lammps_13Jul2023_gcc1020.md)

Run Instructions
------------------

* [OpenFOAM/dummy-LAMMPS test CPLTestSocketFoam Run Instructions](run_CPLTestSocketFoam.md)
* [LAMMPS/dummy-OpenFOAM test Couette_coupled/Partial_overlap Run Instructions](run_Couette_coupled_Partial_overlap.md)
* [LAMMPS/OpenFOAM test LAMMPS_OPENFOAM Run Instructions](run_LAMMPS_OPENFOAM.md)


Notes
-----
These examples see both applications share the same MPI_Comm_world communicator. The alternative is where each application uses their own MPI_Comm_world communicators.  

Basic examples of both these modes (shared and distinct heterogenous jobs) can can be found in the cpl-library/examples/minimal_send_recv_mocks folder, with Archer2 batch scripts shared.bat and distinct.bat within cpl-library/examples/minimal_send_recv_mocks/archer2_examples/.  

NB all examples in cpl-library, CPL_APP_OPENFOAM and CPL_APP_LAMMPS-DEV can run in either mode on Arhcer2 where only the batch script requires changing, i.e., all applications can be run in either shared or distinct modes.
