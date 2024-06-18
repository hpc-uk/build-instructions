UCX
===

This folder contains instructions for building UCX libraries on various UK HPC systems.

Unified Communication X is an open-source, production-grade communication framework for data-centric
and high-performance applications. See the [OpenUCX home page](https://www.openucx.org/).

The UCX API is typically used for the Point-to-point Management Layer (PML) within OpenMPI's Modular Component Architecture (MCA).
For that reason, the UCX libraries are not used directly: the UCX library paths are required when building OpenMPI
(see the --with-ucx configure option).

Build Instructions
------------------

* [UCX 1.15.0 Tursa GPU Build Instructions (GCC 9, CUDA 12.3)](build_ucx_1.15.0_tursa-gpu_gcc9.md)
* [UCX 1.15.0 Tursa CPU Build Instructions (GCC 9)](build_ucx_1.15.0_tursa-cpu_gcc9.md)
* [UCX 1.16.0 Cirrus Build Instructions (GCC 10)](build_ucx_1.16.0_cirrus_gcc10.md)
* [UCX 1.15.0 Cirrus Build Instructions (GCC 10)](build_ucx_1.15.0_cirrus_gcc10.md)

Notes
-----
