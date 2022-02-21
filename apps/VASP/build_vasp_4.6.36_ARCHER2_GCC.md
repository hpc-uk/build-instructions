Instructions for compiling VASP 4.6.36 for ARCHER2 using GCC compilers
======================================================================

These instructions are for compiling VASP 4.6.36 on [ARCHER2](https://www.archer2.ac.uk)
using the GCC compilers.

We assume that you have obtained the VASP source code from the VASP website along
with any relevant patches.

Setup correct modules
---------------------

Load the GCC programming environment, switch to older GCC version (GCC 10 fails to build
VASP successfully) and load the FFTW library module:

```bash
module load PrgEnv-gnu
module load cray-fftw
```

Build the libraries
-------------------

Use [Makefile.lib.HPECrayEX_GCC](Makefile.lib.HPECrayEX_GCC) to build the libraries

```bash
cd vasp.6.lib
make -f Makefile.HPECrayEX_GCC
```

Modify the preprocessor directives in the source code
-----------------------------------------------------

The preprocessor directives in some of the VASP 4 source code are not compatible
with standard preprocessing tools so use the [modsource.bash](modsource.bash) script
to fix these before compiling. The script contains the following lines:

```bash
files=$(ls *.F)
for file in $files
do
  echo $file
  sed -i 's/^\s*#/#/' $file
done
```

Place the script in the `vasp.4.6` directory with the source code files and run

```bash
bash modsource.bash
```

Compile the VASP code
---------------------

Now you can compile the VASP source code using [Makefile.HPECrayEX_GCC](Makefile.HPECrayEX_GCC).

Note that this makefule has been modified to run the preprocessor in a different
way from the standard makefiles in the VASP 4 source code (it uses a process that is more
similar to that used for VASP 5 and 6).

```bash
make -f Makefile.HPECrayEX_GCC clean
make -f Makefile.HPECrayEX_GCC
```

If you want to build the Gamma-point or non-collinear versions of VASP 4 you should
modify Makefile.HPECrayEX_GCC to add the correct additional preprocessor directives:

 - Gamma-point: **add** `-DwNGZhalf`
 - Non-collinear: **remove** `-DNGZhalf`



