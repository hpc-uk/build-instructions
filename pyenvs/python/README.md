Python
======

This folder contains the documentation for building Miniconda Python environments in a manner
suitable for various HPC machine platforms.

History
-------

Date | Person | System | Version | Notes
---- | -------|--------|---------|------
2023-03-21 | Michael Bareford | Cirrus | 3.7.16 | Python Build instructions for Cirrus CPU nodes
2022-09-12 | Michael Bareford | Cirrus | 3.9.13 | Python Build instructions for Cirrus CPU nodes
2024-06-12 | Michael Bareford | Cirrus | 3.12.1 | Python Build instructions for Cirrus CPU nodes
2023-05-02 | Michael Bareford | Cirrus | 3.8.13 | Python Build instructions for Cirrus GPU nodes
2022-10-05 | Michael Bareford | Cirrus | 3.9.13 | Python Build instructions for Cirrus GPU nodes
2023-01-17 | Michael Bareford | Cirrus | 3.10.8 | Python Build instructions for Cirrus GPU nodes
2024-02-14 | Michael Bareford | Cirrus | 3.11.5 | Python Build instructions for Cirrus GPU nodes
2024-06-12 | Michael Bareford | Cirrus | 3.12.1 | Python Build instructions for Cirrus GPU nodes


Build Instructions
------------------

* [Python 3.7.16 Cirrus Build Instructions (CPU)](build_python_3.7.16_cirrus_cpu.md)
* [Python 3.9.13 Cirrus Build Instructions (CPU)](build_python_3.9.13_cirrus_cpu.md)
* [Python 3.12.1 Cirrus Build Instructions (CPU)](build_python_3.12.1_cirrus_cpu.md)
* [Python 3.8.16 Cirrus Build Instructions (GPU)](build_python_3.8.16_cirrus_gpu.md)
* [Python 3.9.13 Cirrus Build Instructions (GPU)](build_python_3.9.13_cirrus_gpu.md)
* [Python 3.10.8 Cirrus Build Instructions (GPU)](build_python_3.10.8_cirrus_gpu.md)
* [Python 3.11.5 Cirrus Build Instructions (GPU)](build_python_3.11.5_cirrus_gpu.md)
* [Python 3.12.1 Cirrus Build Instructions (GPU)](build_python_3.12.1_cirrus_gpu.md)


Notes
-----

The various sets of build instructions listed above all build a Python environment on Cirrus
containing an `mpi4py` linked to OpenMPI 4.1.6. The instructions have to be amended slightly
if you wish to link to one of the other MPI libraries available on Cirrus.

If you wish to link mpi4py with either HPE MPT or Intel MPI for example, you must, instead of
loading the OpenMPI module, load either `mpt/2.25` or `intel-mpi-19`, depending on preference.
Following this you must explicitly load a `gcc` module, e.g., `gcc/10.2.0`. The only other
instruction that differs is the one that builds the `mpi4py` package: the compiler environment
variables must be set to the appropriate MPI wrappers.

```bash
CC=mpicc CXX=mpicxx FC=mpif90 python setup.py build
```
