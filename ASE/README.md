ASE
===

This folder contains files and documentation for building ASE on UK
HPC systems.

History
-------

 Date | Person | System | Version | Notes
 ---- | ------ | ------ | ------- | -----
 2019-04-01 | Mark Filipiak | ARCHER (EPCC), Xeon Ivy Bridge | 3.17.0 | With Python 3.6, GCC 6.
 2019-04-23 | Mark Filipiak | ARCHER (EPCC), Xeon Ivy Bridge | 441bb707d | With Python 3.6, GCC 6, updated to Numpy 1.16.2, Scipy 1.2.1

Build Instructions
------------------

* [ASE 3.17.0 ARCHER (EPCC), Xeon Ivy Bridge, Python 3.6, GCC 6 Build Instructions](3.17.0_ARCHER_IvyBridge_python3_gcc6/README.md)
* [ASE 441bb707d ARCHER (EPCC), Xeon Ivy Bridge, Python 3.6, GCC 6 Build Instructions](441bb707d_ARCHER_IvyBridge_python3_gcc6/README.md)

Notes
-----

3.17.0 does not work with Numpy 1.16.2, it may work with Numpy 1.15.4

441bb707d (Git SHA of the HEAD of the master branch at the time) works
with Numpy 1.16.2.  441bb707d is not a release, but the ASE developers
say that the master branch is usually quite stable.
