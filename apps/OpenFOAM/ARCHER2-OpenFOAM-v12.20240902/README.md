# OpenFOAM v12

This is OpenFOAM version 12 (patch version released 2nd September 2024).
See https://openfoam.org/news/v12-patch/

This page contains a subdirectory [site](./site) with the
following scripts which allow one to install and compile OpenFOAM
using the Gnu compiler collection on Archer2.
```
./site/compile.sh
./site/etc
./site/install.sh
./site/modules.sh
./site/q-compile.sh
./site/q-test.sh
./site/test.sh
./site/version.sh
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

## Compile

Compilation is currently carried using a batch script
```
$ sbatch --account=X ./site/q-compile.sh
```
Note that this will take around 1 hour. The `X` should be replaced by your
account code.

## Example SLURM submission script

A short smoke test `./site/q-test.sh` is provided, which is intended for the
queue system. The script can be used as a template for jobs to be
submitted via:
```
$ sbatch --account=X ./site/q-test.sh
```
where `X` should be replaced by your account code.
