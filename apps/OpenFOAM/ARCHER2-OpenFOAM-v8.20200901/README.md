# OpenFOAM v8

This is OpenFOAM version 8 (patch version released 1st September 2020).
See https://openfoam.org/news/v8-patch/

This directory contains a subdirectory `site` with the
following scripts which allow one to install and compile OpenFOAM
using the Gnu compiler collection on Archer2.
```
./site/compile.sh
./site/etc
./site/etc/prefs.h
./site/install.sh
./site/modules.sh
./site/preconfigure.sh
./site/q-compile.sh
./site/q-test.sh
./site/test.sh
./site/wmake
```

You will need to obtain a copy of this directory to proceed.

## Download

In an appropriate directory run the install script:
```
$ bash ./site/install.sh
```
which will download and unpack the source and third-party packages to the
current location.

## Patch

In the same directory
```
$ bash ./site/pre-configure.sh
```
to perform a number of patches to allow compilation. The local
preferences `./site/etc/prefs.sh` will be located by the
OpenFOAM `./bashrc` script in its current location.

## Compile

Compilation is currently carried out on the front end via
```
$ bash ./site/compile.sh
```
Note that this will take around 1 hour.

## Example SLURM submission script

A short smoke test `./site/q-test.sh` is provided, which is intended for the
queue system. The script can be used as a template for jobs to be
submitted via:
```
$ sbatch --account=X ./site/q-test.sh
```
where `X` should be replaced by your account code.
