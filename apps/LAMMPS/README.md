LAMMPS
======

This folder contains files and documentation for building and maintaining LAMMPS on various HPC facilities.

To keep files sorted, the LAMMPS default version names of DDMonYYYY is changed to the sensible ISO 8601 format in the markdown file names.
Elsewhere, the original nomenclature is used.

The filename format used is:

`<System name>_<DATE in ISO8601 format>_<compiler and version_<further packages with version>.md`

Patched versions of stable releases can have two names - the original date with an update number, or the new date, for example:
version `7Jan2022` is the same as version `29Sep2021 update 2`.
All the available versions are on the [LAMMPS github releases page](https://github.com/lammps/lammps/releases).

History
-------

| Date       | Person         | System   | Version   | Notes                                         |
| ---------- | ------------   | -------- | --------- | -----                                         |
| 2017-06-05 | Andy Turner    | Cirrus   | 31Mar2017 | GCC 6.2.0 compilers and MPT 2.14              |
| 2020-06-23 | Luis Cebamanos | Cirrus   | 3Mar2020  | Intel 19 compilers and MPT 2.22               |
| 2020-10-15 | Julien Sindt   | ARCHER2  | 3Mar2020  | GCC 9.3.0 compilers                           |
| 2022-01-19 | Julien Sindt   | ARCHER2  | 7Jan2022  | GCC 10.2.0 compilers                          |
| 2022-09-06 | Julien Sindt   | Cirrus   | 6Aug2022  | Intel 19 compilers and MPT 2.25               |
| 2023-02-01 | Julien Sindt   | ARCHER2  | 3Nov2022  | GCC 11.2.0 compilers                          |
| 2023-02-22 | Julien Sindt   | Cirrus   | 17Feb2023 | GCC 8.2.0 compilers and intel MPI             |
| 2023-02-23 | Rui Apóstolo   | Cirrus   | 17Feb2023 | GCC 8.2.0 compilers, intel MPI, and CUDA 11.8 |
| 2023-03-09 | Rui Apóstolo   | ARCHER2  | 17Feb2023 | GCC 10.3.0 compilers                          |

Build Instructions
------------------

* [LAMMPS 31Mar2017 Cirrus Build Instructions (GCC 6, MPT 2.14)](Cirrus_2017-03-31_gcc620_mpt214.md)
* [LAMMPS 15Oct2020 ARCHER2 Build Instructions (GCC 9.3.0)](ARCHER2_2020-03-03_gcc930.md)
* [LAMMPS 2Feb2023 Cirrus Build Instructions (GCC 8.4.1, intel mpi)](Cirrus_2023-02-17_gcc841_impi.md)
* [LAMMPS 2Feb2023 Cirrus Build Instructions (GCC 8.4.1, intel mpi, CUDA 11.8)](Cirrus_2023-02-17_gcc841_impi_cuda118.md)

Notes
-----

When writing new build instructions, use the `--branch <tag>` instead of `--branch stable` flag on the `git clone` command, to ensure that the instructions are always valid, even when the LAMMPS stable version changes.
Always load modules with a version number, even if it's the default in that system.
The file header should take the form: `Building LAMMPS <version> on <system> (<compiler with version>, <other packages>)`

Example:

Building LAMMPS 31Mar2017 on Cirrus (GCC 6.2.0, SGI MPT 2.14)
