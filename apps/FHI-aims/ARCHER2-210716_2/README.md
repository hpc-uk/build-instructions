# FHI-aims

FHI-aims (see, e.g., https://fhi-aims.org) is usually compiled by individual
users who first must have obtained a license.

FHI-aims is available to registered users as

```
$ git clone https://aims-git.rz-berlin.mpg.de/aims/FHIaims.git
```

However, here we discuss a bundled stable release version downloaded as
`fhi-aims.210716_2.tgz`.

## Scripts

One of the accompanying scripts may be used to build the code
in either `PrgEnv-cray`, `PrgEnv-gnu` (`PrgEnv-aocc` is under
investigation).

Run the relevant script interactively in a suitable location containing
the tar bundle, e.g., for `PrgEnv-gnu`
```
$ bash ./build-gnu.sh
```

We give a brief overview here.

The script untars the bundle into a sub-directory (the top-level FHI-aims
directory) which will be referred to as `FHI_AIMS_ROOT`:
```
tar xf fhi-aims.210716_2.tgz
cd fhi-aims.210716_2
export FHI_AIMS_ROOT=`pwd`
```
A build directory is created and an `initial_cache.cmake` file is
generated with relevant compiler names, and compiler options. We
have selected relatively conservative optimisation settings here.

The configuration and build stages are then run with
```
cmake -C initial_cache.cmake ..
make -j 16
```

The build should take 10--15 minutes.


## Test job submission

For either build, we can use one of the standard test benchmarks provided

```
${FHI_AIMS_ROOT}/benchmarks/Ac-Lys-Ala19-H/control.in
${FHI_AIMS_ROOT}/benchmarks/Ac-Lys-Ala19-H/geometry.in
```

The results can be compared with one of the reference results provided, e.g.,
in directory:
```
${FHI_AIMS_ROOT}/benchmarks/Ac-Lys-Ala19-H/reference.hydra.48cores
```

We include submission script for a 48-core job `submit-48.sh`. Again, we use
the `PrgEnv-gnu` build as an example.

You will need to set `FHI_AIMS_ROOT` appropriately.






