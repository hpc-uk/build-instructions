Build Instructions
------------------

glibc on Archer is 2.11.  Some later versions of glibc (2.12 to 2.16)
can be built and used but these have not been properly tested.  The
[glibc wiki](https://sourceware.org/glibc/wiki/HomePage) gives details
of how glibc can be tested, and how it should be used.

glibc 2.17 does not build - perhaps a later gcc is needed, or the
system calls are too old.

Use the oldest glibc that can be used with the program that is to be
run, so that it is as close as possible to the system libraries.

Use the system gcc, since glibc is so close to the system.  Possibly a
later gcc should be used for later glibc versions (e.g., is this why
2.17 does not compile?).

If a system call is not available on Archer (e.g., prlimit/prlimit64),
then recent glibc functions that use them will not work (e.g., prlimit
in glibc 2.16 gives a compile warning "is not implemented and will
always fail" and run error ENOSYS "Function not implemented").

Kernel version 2.6.4 is mentioned for many of the existing shared
libraries.  This SHOULD mean that new glibc is used only when it is
needed (i.e., when version required is greater than the system one).
Choosing 2.6.5 appears to make the new glibc be always used in
preference.  Using 2.6.4 would be preferable, but then we get
segmentation faults unless LD_LIBRARY_PATH is set, which will force
use of the new glibc anyway.

There is a maintenance problem with setting up the cache once.  For
example, later Cray module changes will not be included, and will
require a ldconfig.  Probably we should specify kernel version 2.6.4,
and use LD_LIBRARY_PATH, and not set up the cache, and somehow use the
system cache (I don't know if the last is possible).  Also is /lib and
/usr/lib used or $glibc_dir/lib and $glibc_dir/usr/lib?

The installation directory must be on `/work` to be sure that shared
libraries are accessible from the compute nodes (aprun will resolve
these but a program might run dlopen).

Change directory to the build directory, here
`/work/z01/shared/glibc_test` and copy and edit [these scripts]().
The build directory and the batch account codes (here `z19-cse`) will
need to be changed in the scripts.

### Download and unpack

Use [`download.bash`](download.bash) and [`unpack.bash`](unpack.bash)

### Build and test

Run [`build.bash`](build.bash)

```bash
./build.bash
```

Check `configure.log`, `make.log`, and `install.log`.  The build
script also creates an `ld.so.cache` for the new glibc.


Run [`test.pbs`](test.pbs)

```bash
qsub test.pbs
```

and check the PBS error and output files.  It is better to modify the
test script to use the program that needs the new glibc - that will be
a proper test.

### Change permissions

```bash
chmod -R a+rX /work/z01/shared/glibc_test
```

### Set up the module

No module has been set up.

### Make a backup

`/work` is not backed up, `tar` everything safely on `/home`

```bash
mkdir -p /home/z01/shared/glibc_test
chmod -R a+rX /home/z01/shared/glibc_test
cd /work/z01/shared/glibc_test
tar czf /home/z01/shared/glibc_test/copy_of_work.tgz .
chmod a+r /home/z01/shared/glibc_test/copy_of_work.tgz
```

Restore using

```bash
mkdir -p /work/z01/shared/glibc_test
cd /work/z01/shared/glibc_test
tar xf /home/z01/shared/glibc_test/copy_of_work.tgz
chmod -R a+rX /work/z01/shared/glibc_test
```

### Help improve these instructions

If you make changes that would update these instructions, please fork
this repository on GitHub, update the instructions and send a pull
request to incorporate them into this repository.

Notes
-----
