Instructions for compiling Py-ChemShell 23.0.1 using GCC 11.2.0 on ARCHER2
==========================================================================

These instructions are for compiling pyChemShell (optionally with NWChem and 
with GULP) on [ARCHER2](https://www.archer2.ac.uk) using the GCC 11 compilers.

Obtaining source code
---------------------

You must source Py-ChemShell and GULP (if you intend to use it) source code yourself. You can obtain Py-ChemShell via the website [here](https://chemshell.org/licence/) after registering. GULP can likewise be obtained on its website [here](https://gulp.curtin.edu.au/download.html). Please note the conditions of download and use.

Compiling Py-ChemShell
----------------------

The Py-ChemShell setup script will set up your environment for you. A basic
install of Py-ChemShell in the source directory can be achieved by running the following commands, moving into the Py-ChemShell source code directory and running a simple build command:

```bash
  cd chemsh-py/
  ./setup --platform archer2
```

You don't need to worry about setting up the build environment -- the `setup.py` script will take care of this for you.

Compiling Py-ChemShell with NWChem 7.2.2
----------------------------------------

To use NWChem with Py-ChemShell, firstly run the simple installation from the previous step, then, when it is finished, run the following in the Py-ChemShell source directory:

```bash
  ./setup --platform archer2 --nwchem
```

This will download the latest version of the NWChem source code (7.2.2 at the time of writing), compile it and add it to your installation.

Be aware that this step can take an hour or more.

Compiling Py-ChemShell with GULP 6.2
------------------------------------

For this, you will need to obtain the GULP source code as noted above. Extract the archive and note its location.

Once you have completed *both* of the above two `setup` commands, run the following in the Py-ChemShell source directory to add GULP, where you should provide the correct path to your GULP source directory.

```bash
  ./setup --platform archer2 --nwchem --gulp /path/to/your/gulp-6.2/
```

Tests
-----

Regression tests are provided in the `chemsh-py/tests` directory. Run individual tests as input to `chemsh` or run the `test` Python script.