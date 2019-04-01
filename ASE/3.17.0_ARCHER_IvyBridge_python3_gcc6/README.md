Build Instructions
------------------

These instructions and the scripts and modulefile are for the `cse`
user in the `y07` group, with the `y07` budget - change these to your
username and group and budget, and change directory and file names as
desired.  The installation directory must be on `/work`.

### Build and test

Change directory to the build directory, here
`/home/y07/y07/cse/ase/3.17.0_build2` and copy [these scripts]()

There is no need to download and build, just use `pip`; see
[`build.bash`](build.bash)

There are certificate errors if [`build.bash`](build.bash) is run, but sourcing it
works:

```bash
. ./build.bash &> build.log
```

Check `module.log` and `build.log`, then run [`test.pbs`](test.pbs)

```bash
qsub test.pbs
```

Wait a few minutes and check the logs in
`/work/y07/y07/cse/ase/3.17.0_build2/test`

Using Python 2 the tests fail - an error in the test script.  Using
Python 3 many tests are skipped (no chemistry packages), there are
several warnings, but all tests pass.

The tests do seem to take 4 times as long on a compute node as on a
login node.


### Change permissions

```bash
chmod -R +rX /home/y07/y07/cse/ase/3.17.0_build2
chmod -R +rX /work/y07/y07/cse/ase/3.17.0_build2
```

### Set up the module

(For CSE use, but you can set up a module in your own project
similarly.)

Copy the [`modulefile`](modulefile)

```bash
su - packmods
cd modulefiles-archer/pc-ase
cp -p /home/y07/y07/cse/ase/3.17.0_build2/modulefile 3.17.0_build2
```

### Make a backup

`/work` is not backed up, `tar` everything safely on `/home`.  In
`/work/y07/y07/cse/ase/3.17.0_build2` do

```bash
tar czf /home/y07/y07/cse/ase/3.17.0_build2/copy_of_work.tgz .
chmod +r /home/y07/y07/cse/ase/3.17.0_build2/copy_of_work.tgz
```

Restore using

```bash
mkdir -p /work/y07/y07/cse/ase/3.17.0_build2
cd /work/y07/y07/cse/ase/3.17.0_build2
tar xf /home/y07/y07/cse/ase/3.17.0_build2/copy_of_work.tgz
chmod -R +rX /work/y07/y07/cse/ase/3.17.0_build2
```

### Help improve these instructions

If you make changes that would update these instructions, please fork
this repository on GitHub, update the instructions and send a pull
request to incorporate them into this repository.

Notes
-----
