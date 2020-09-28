# AmberTools20 (no Amber)

You need to fill in the web form at
https://ambermd.org/GetAmber.php#ambertools
to download the source code bundle `AmberTools20.tar.bz2`.

You also need the two accompanying bash scripts from this
directory. See comments in the scripts for details.

Arrange the three files is a suitable location in the Cirrus filesystem

```
$ ls
AmberTools20.tar.bz2  build-ambertools-gnu.sh  build-parallel-netcdf-gnu.sh
```

From the same directory, run the script to install parallel netcdf:

```
$ bash ./build-parallel-netcdf-gnu.sh
```

Run the script to install Ambertools

```
$ bash ./build-ambertools-gnu.sh
```

This takes about 30 minutes and will build, in turn, the serial version and
then the parallel version using MPI.

On success, you may need to source the amber.sh script:

```
$ source ./amber20_src/amber.sh
```

to set the relevant environment variables to use AmberTools.

## Run time

At run time, a consistent set of modules is required so that dynamic
libraries can be located:

```
module load mpt/2.22
module load gcc/6.3.0
module load anaconda/python3
```

