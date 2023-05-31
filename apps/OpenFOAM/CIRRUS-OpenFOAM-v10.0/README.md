# OpenFOAM v10

This is OpenFOAM v10. (Patch released January 2023)
See https://openfoam.org/news/v10-patch/

Here using gcc (default gcc/8.2.0) and mpt (default mpt/2.25)

Copy the `site` subdirectory to a suitable location. This location
should then contain
```
./site/install.sh
./site/modules.sh
./site/compile.sh
./site/prefs.sh
./site/q-compile.sh
./site/q-test.sh
./site/version.sh
```

## Download

From this location run the install script
```
$ bash ./site/install.sh
```
to download and unpack the source and third party packages.

## Compile

Compile on the front end with
```
$ bash ./site/compile.sh
```
This may take up to 2 hours. It can be useful to run the compile
script twice to obtain a clear picture of the state of the build.


## Example SLURM submission

The file `./site/q-test.sh` contains a short smoke test, but can also
be used as a template for batch jobs submitted, e.g.,
```
$ sbatch --account=X ./site/q-test.sh
```
where `X` should be replaced by your account code.

