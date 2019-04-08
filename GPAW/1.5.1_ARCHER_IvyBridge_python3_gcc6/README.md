Build Instructions
------------------

These instructions and the scripts and modulefile are for the `cse`
user in the `y07` group, with the `y07` budget - change these to your
username and group and budget, and change directory and file names as
desired.  The installation directory must be on `/work`.

Change directory to the build directory, here
`/home/y07/y07/cse/gpaw/1.5.1_build3` and copy and edit [these scripts]()

### Download and unpack

Use [`download.bash`](download.bash) and [`unpack.bash`](unpack.bash)

### Build and test

Run [`build.bash`](build.bash)

```bash
./build.bash &> build.log
```

Check `module.log` and `build.log`, then run [`test.pbs`](test.pbs)

```bash
qsub test.pbs
```

Wait several hours (queue time plus 4 hours run time) and check the logs in
`/work/y07/y07/cse/gpaw/1.5.1_build3/test`

Using Python 2 many tests fail - possibly a problem with ASE.

Using Python 3 the serial tests fail - an error in the test script.
The parallel tests pass except the atoms_too_close test - it is not
clear why this fails.

### Change permissions

```bash
chmod -R a+rX /home/y07/y07/cse/gpaw/1.5.1_build3
chmod -R a+rX /work/y07/y07/cse/gpaw/1.5.1_build3
```

### Set up the module

(For CSE use, but you can set up a module in your own project
similarly.)

Copy the [`modulefile`](modulefile)

```bash
su - packmods
cd modulefiles-archer/gpaw
cp -p /home/y07/y07/cse/gpaw/1.5.1_build3/modulefile 1.5.1_build3
```

### Make a backup

`/work` is not backed up, `tar` everything safely on `/home`.  In
`/work/y07/y07/cse/gpaw/1.5.1_build3` do

```bash
tar czf /home/y07/y07/cse/gpaw/1.5.1_build3/copy_of_work.tgz .
chmod a+r /home/y07/y07/cse/gpaw/1.5.1_build3/copy_of_work.tgz
```

Restore using

```bash
mkdir -p /work/y07/y07/cse/gpaw/1.5.1_build3
cd /work/y07/y07/cse/gpaw/1.5.1_build3
tar xf /home/y07/y07/cse/gpaw/1.5.1_build3/copy_of_work.tgz
chmod -R a+rX /work/y07/y07/cse/gpaw/1.5.1_build3
```

### Help improve these instructions

If you make changes that would update these instructions, please fork
this repository on GitHub, update the instructions and send a pull
request to incorporate them into this repository.

Notes
-----
