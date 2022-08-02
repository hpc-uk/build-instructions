Instructions for compiling pyChemShell 21.0.1 using GCC10 on ARCHER2
====================================================================

These instructions are for compiling pyChemShell (optionally with NWChem and 
with GULP) on [ARCHER2](https://www.archer2.ac.uk) using the GCC 10 compilers.

Downloading and compiling pyChemShell
-------------------------------------

The pyChemShell setup script will set up your environment for you. A basic 
install of pyChemShell can be achieved by running:

```bash
  git clone --recursive https://gitlab.stfc.ac.uk/chemshell/chemsh-py.git
  cd chemsh-py/
  git checkout -b 21.0.1
  ./setup --platform archer2
```

Compiling pyChemShell with NWChem 7.0.2
---------------------------------------

You can compile pyChemShell and download and compile NWChem by running:

```bash
  ./setup --platform archer2 --nwchem
```

Be aware that this compilation can take up to 45 minutes.

Compiling pyChemShell with NWChem 7.0.2 and GULP 6.0
----------------------------------------------------

For this, you will first need to download and compile GULP 6.0:

```bash
  cd ../
  tar -xvf gulp-6.0.tar.gz
  cd gulp-6.0/Src
  module load PrgEnv-gnu
  ./mkgulp clean
  ./mkgulp -c cray -m -t lib
```

Once this compilation is complete, run the following to compile pyChemShell 
with NWChem and GULP:

```bash
  cd ../../chemsh-py
  ./setup --platform archer2 --nwchem --gulp ../gulp-6.0/
```
