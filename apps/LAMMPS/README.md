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

Older versions of LAMMPS could only be compiled by editing several makefiles and then using `make`.
Recent (2020 and later) versions of LAMMPS can also be compiled using `cmake`, which can be configured using only one (long) command.

History
-------

| Date       | Person           | System   | Version   | Notes and link                                                                                   |
| ---------- | ------------     | -------- | --------- | --------------                                                                                   |
| 2017-06-05 | Andy Turner      | Cirrus   | 31Mar2017 | [GCC 6.2.0 compilers and MPT 2.14](Cirrus_2017-03-31_gcc620_mpt214.md)                           |
| 2020-06-23 | Luis Cebamanos   | Cirrus   | 3Mar2020  | [Intel 19 compilers and MPT 2.22](Cirrus_2020-03-03_intel19_mpt222.md)                           |
| 2020-10-15 | Julien Sindt     | ARCHER2  | 3Mar2020  | [GCC 9.3.0 compilers](ARCHER2_2020-03-03_gcc930.md)                                              |
| 2022-01-19 | Julien Sindt     | ARCHER2  | 7Jan2022  | [GCC 10.2.0 compilers](ARCHER2_2022-01-07_gcc1020.md)                                            |
| 2022-09-06 | Julien Sindt     | Cirrus   | 6Aug2022  | [Intel 19 compilers and MPT 2.25](Cirrus_2022-08-06_intel19_mpt225.md)                           |
| 2023-02-01 | Julien Sindt     | ARCHER2  | 3Nov2022  | [GCC 11.2.0 compilers](ARCHER2_2022-11-03_gcc1120.md)                                            |
| 2023-02-22 | Julien Sindt     | Cirrus   | 17Feb2023 | [GCC 8.2.0 compilers and intel MPI](Cirrus_2023-02-17_gcc820_impi.md)                            |
| 2023-02-23 | Rui Apóstolo     | Cirrus   | 17Feb2023 | [GCC 8.2.0 compilers, intel MPI, and CUDA 11.8](Cirrus_2023-02-17_gcc820_impi_cuda118.md)        |
| 2023-03-09 | Rui Apóstolo     | ARCHER2  | 17Feb2023 | [GCC 10.3.0 compilers](ARCHER2_2023-02-17_gcc1030.md)                                            |
| 2024-01-10 | Rui Apóstolo     | ARCHER2  | 15Dec2023 | [CPE 22.12 compilers](ARCHER2_2023-12-15_cpe2212.md)                                             |
| 2024-02-15 | Rui Apóstolo     | Cirrus   | 15Dec2023 | [GCC 10.2.0 compilers, intel MPI 20.4](Cirrus_2023-12-15_gcc10.2_impi20.4.md)                    |
| 2024-02-20 | Rui Apóstolo     | Cirrus   | 15Dec2023 | [GCC 10.2.0 compilers, intel MPI 20.4, CUDA 11.8](Cirrus_2023-12-15_gcc10.2_impi20.4_cuda118.md) |
| 2023-03-09 | Eleanor Broadway | ARCHER2  | 17Feb2023 | [HIP compilers, CPE, ROCM 5.2.3](ARCHER2_2023_09_23_cce15_rocm5.2.3.md)                          |
| 2024-05-17 | Rui Apóstolo     | ARCHER2  | 13Feb2024 | [CPE 22.12 compilers](ARCHER2_2024-02-13_cpe2212.md)                                             |
| 2024-05-29 | Rui Apóstolo     | Cirrus   | 02Mar2024 | [GCC 10.2.0 compilers, intel MPI 20.4](Cirrus_2024-03-02_gcc10.2_impi20.4.md)                    |
| 2024-05-29 | Rui Apóstolo     | Cirrus   | 02Mar2024 | [GCC 10.2.0 compilers, intel MPI 20.4, CUDA 12.4](Cirrus_2024-03-02_gcc10.2_impi20.4_cuda124.md) |


Contributing
------------

* When writing new build instructions, use the `--branch <tag>` instead of `--branch stable` flag on the `git clone` command, to ensure that the instructions are always valid, even when the LAMMPS stable version changes.

* Always load modules with a version number, even if it's the default in that system.

* The file first title should take the form `Building LAMMPS <version> on <system> (<compiler with version>, <other packages>)`, for example, `Building LAMMPS 31Mar2017 on Cirrus (GCC 6.2.0, SGI MPT 2.14)`
