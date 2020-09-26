# AmberTools20 (no Amber)

You need to fill in the web form at
https://ambermd.org/GetAmber.php#ambertools
to download the source code bundle AmberTools20.tar.bz2.

You also need the two accompanying bash scripts from this
directory. See comments in the scripts for details.

Arrange the three files is a suitable location in the Cirrus filesystem

```
$ ls
```

From the same directory, run the script to install parallel netcdf:

```
$ bash ./build-parallel-netcdf-gnu.sh
```

Run the script to install Ambertools

```
$ bash ./build-ambertools-gnu.sh
```

This takes 20-30 minutes.

On success, you may need to source the amber.sh script:

```
$ source ./amber20_src/amber.sh
```

to set the relevant environment variables to use AmberTools.
