UCX
===

This folder contains instructions for building UCX libraries on UK HPC systems.

Unified Communication X is an open-source, production-grade communication framework for data-centric
and high-performance applications. See the [OpenUCX home page](https://www.openucx.org/).

The UCX API is typically used for the Point-to-point Management Layer (PML) within OpenMPI's Modular Component Architecture (MCA).
For that reason, the UCX libraries are not used directly: the UCX library paths are required when building OpenMPI
(see the --with-ucx configure option).

History
-------

 Date | Person | System | Version | Notes
 ---- | ------ | ------ | ------- | -----
 2022-03-17 | Michael Bareford | Cirrus | 1.9.0 | GCC 8.2.0
 2022-03-17 | Michael Bareford | Cirrus | 1.12.0 | GCC 8.2.0

Build Instructions
------------------

* [UCX 1.9.0 Cirrus Build Instructions (GCC 8)](build_ucx_1.9.0_cirrus_gcc8.md)
* [UCX 1.12.0 Cirrus Build Instructions (GCC 8)](build_ucx_1.12.0_cirrus_gcc8.md)

Notes
-----

There is currently an issue when using UCX 1.12.0 with OpenMPI 4.1.2 on Cirrus: a simple MPI broadcast gives
`Segmentation fault: address not mapped to object at address (nil)` from within the UCX `libucs.so.0` library.
The workaround is to use OpenMPI with UCX 1.9.0 instead.
