# OpenFOAM v2106

This is OpenFOAM release of June 2021 (v2106).
See e.g., https://www.openfoam.com/news/main-news/openfoam-v2106

This directory contains a subdirectory `site` with the
following scripts which allow one to install and compile OpenFOAM
using the Gnu compiler collection on Cirrus.
```
./site/compile.sh
./site/install.sh
./site/modules.sh
./site/prefs.sh
./site/q-test.sh
./site/test.sh
./site/version.sh
```

You will need to obtain a copy of this directory to proceed.

## Download

In an appropriate directory run the install script:
```
$ bash ./site/install.sh
```
which will download and unpack the source and third-party packages to the
current location. The `install` script will also copy the local
preferences `prefs.sh` to `OpenFOAM-v2106/etc`. See
the `install.sh` script for details.

## Compile

Compilation may be carried out on the front end via
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
