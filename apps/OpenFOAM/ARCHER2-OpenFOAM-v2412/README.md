# OpenFOAM v2412

This is OpenFOAM release of December 2024 (v2412).
See, e.g., https://www.openfoam.com/news/main-news/openfoam-v2412


This directory contains a subdirectory `site` with the
following scripts which allow one to install and compile OpenFOAM
using the Gnu compiler collection on Archer2.
```
./site/compile.sh
./site/install.sh
./site/modules.sh
./site/prefs.sh
./site/q-compile.sh
./site/q-test.sh
./site/test.sh
```

You will need to obtain a copy of this directory to proceed.

## Download

In an appropriate directory run the install script:
```
$ bash ./site/install.sh
```
which will download and unpack the source and third-party packages to the
current location. The `install` script will also copy the local
preferences `prefs.sh` to `OpenFOAM-v2412/etc`, and make a small number of
patches to the third party configuration to allow it to compile. See
the `install.sh` script for details.

## Compile

Compilation may be carried out in the queue system via
```
$ sbatch ./site/q-compile.sh
```
This will take around 2 hours. A successful build will give a log
reporting the finish time at the end.

## Example SLURM submission script

A short smoke test `./site/q-test.sh` is provided, which is intended for the
queue system. The script can be used as a template for jobs to be
submitted, e.g., via:
```
$ sbatch ./site/q-test.sh
```

