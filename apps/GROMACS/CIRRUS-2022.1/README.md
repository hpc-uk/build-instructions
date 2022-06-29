# Gromacs 2022.1 on Cirrus

## CPU version

In an appropriate location in `/work`, run the accompanying script
```
$ bash ./build-cpu.sh
```
For further details, read the script. The script builds both the serial
and the parallel (MPI) version.


## GPU version

The analogous script for the GPU build is:
```
$ ./build-gpu-mpt.sh
```
This build does not attempt to use the GPU-aware MPI.
