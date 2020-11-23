Build Instructions
------------------

These instructions and the scripts and modulefile are for the `cse`
user in the `y07` group, with the `y07` budget - change these to your
username and group and budget, and change directory and file names as
desired.  The installation directory must be on `/work`.

Change directory to the build directory, here
`/home/y07/y07/cse/numpy/1.16.2-python3.6.0-libsci_build1` and copy and edit [these scripts]()

### Download and unpack

Use [`download.bash`](download.bash) and [`unpack.bash`](unpack.bash)

### Build and test

You may need to edit
[`site.cfg-libsci.template`](site.cfg-libsci.template) before
building.  Run [`build.bash`](build.bash)

```bash
./build.bash
```

Check `module.log`, `build.log`, and `install.log` then run
[`test.pbs`](test.pbs)

```bash
qsub test.pbs
```

Wait about 30 minutes and check `test.log`.  One test fails:

TestRealScalars.test_dragon4

assert_equal(fpos64(0.5**(1022 + 52), unique=False, precision=1074), ...)

E       OverflowError: (34, 'Numerical result out of range')

Python (not Numpy) uses C pow for exponentiation.  Although gcc has
builtins for pow, for the cases that Python provides (arbitrary
doubles), the libm function is used.  In the version of libm (2.11.3)
on Archer, pow sets the underflow flag for denormal results (such as
0.5**1074) and errno to ERANGE.  In more recent versions, pow sets the
flag and errno only for a zero result.  Python only allows ERANGE and
zero result, and thus, for Archer, reports the ERANGE error (as an
Overflow), and thus the test fails.  It may be possible to use a newer
libm (i.e., glibc) version but this has not been tested for Python
(nor even for programs that use dlopen).  We accept this test failure.

### Change permissions

```bash
chmod -R a+rX /home/y07/y07/cse/numpy/1.16.2-python3.6.0-libsci_build1
chmod -R a+rX /work/y07/y07/cse/numpy/1.16.2-python3.6.0-libsci_build1
```

### Set up the module

(For CSE use, but you can set up a module in your own project
similarly.)

Copy the [`modulefile`](modulefile).  The
`python-compute/3.6.0_gcc6.1.0` module adds a directory to
`MODULEPATH` for its modules.

```bash
su - packmods
cd modulefiles-python-compute/3.6.0_gcc6.1.0/numpy
cp -p /home/y07/y07/cse/numpy/1.16.2-python3.6.0-libsci_build1/modulefile 1.16.2-libsci_build1
```

### Make a backup

`/work` is not backed up, `tar` everything safely on `/home`.  In
`/work/y07/y07/cse/numpy/1.16.2-python3.6.0-libsci_build1` do

```bash
tar czf /home/y07/y07/cse/numpy/1.16.2-python3.6.0-libsci_build1/copy_of_work.tgz .
chmod a+r /home/y07/y07/cse/numpy/1.16.2-python3.6.0-libsci_build1/copy_of_work.tgz
```

Restore using

```bash
mkdir -p /work/y07/y07/cse/numpy/1.16.2-python3.6.0-libsci_build1
cd /work/y07/y07/cse/numpy/1.16.2-python3.6.0-libsci_build1
tar xf /home/y07/y07/cse/numpy/1.16.2-python3.6.0-libsci_build1/copy_of_work.tgz
chmod -R a+rX /work/y07/y07/cse/numpy/1.16.2-python3.6.0-libsci_build1
```

### Help improve these instructions

If you make changes that would update these instructions, please fork
this repository on GitHub, update the instructions and send a pull
request to incorporate them into this repository.

Notes
-----
