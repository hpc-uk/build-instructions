Spack
=====

This page contains a list of local modifications that have been made to Spack
and Spack packages to make them work on Cirrus.

History
-------

Date | Person | Version | Notes
---- | -------|---------|------
2017-02-01 | Andy Turner |  | Added initial notes
2017-04-13 | Andy Turner |  | Config files and modified packages uploaded

General Configuration
---------------------

* [etc/config.yaml](etc/config.yaml)

Compiler Configuration
----------------------

* [etc/compilers.yaml](etc/compilers.yaml)

Package Configuration
---------------------

* [etc/packages.yaml](etc/packages.yaml)
* [etc/modules.yaml](etc/modules.yaml)

MPI Compiler Configuration
--------------------------

* [repo/mpich-package.py](repo/mpich-package.py) - This is the package.py file from var/spack/repos/builtin/packages/mpich

Package Customisations
----------------------

The following packages have been customised locally on Cirrus. Each of the
files is the package.py file from the appropraite subdirectory in
var/spack/repos/builtin/packages

* [repo/scalasca-package.py](repo/scalasca-package.py)
* [repo/scorep-package.py](repo/scorep-package.py)

