Build Instructions
------------------

These instructions and the scripts and modulefile are for the `cse`
user in the `y07` group, with the `y07` budget - change these to your
username and group and budget, and change directory and file names as
desired.

The build needs to be done on `/work`, since the test suite is not
easiliy changeable to use `aprun`.

The installation directory must be on `/work`.

### Create directories

Make a build directory on `work` and directory for a copy on `/home`


```bash
mkdir -p /work/y07/y07/cse/libxc/4.3.4_build1/GNU/build
mkdir -p /home/y07/y07/cse/libxc/4.3.4_build1/GNU

```

Change directory to the copy directory and copy and edit [this file](README.md).

Change directory to the build directory and copy and edit [these scripts]()

### Download and unpack

Use [`download.bash`](download.bash) and [`unpack.bash`](unpack.bash)

### Build and test

Run [`build.bash`](build.bash)

```bash
./build.bash
```

Wait several hours and check the logs (`module.log`, `configure.log`,
`make.log`, `check.log`) in
`/work/y07/y07/cse/libxc/4.3.4_build1/GNU/build/libxc-4.3.4`

Run [`install.bash`](install.bash)

```bash
./install.bash
```
### Change permissions

```bash
chmod -R +rX /home/y07/y07/cse/libxc/4.3.4_build1
chmod -R +rX /work/y07/y07/cse/libxc/4.3.4_build1
```

### Set up the module

(For CSE use, but you can set up a module in your own project
similarly.)

Copy the [`modulefile`](modulefile)

```bash
su - packmods
cd modulefiles-archer/libxc
mkdir -p 4.3.4_build1
cp -p /work/y07/y07/cse/libxc/4.3.4_build1/modulefile 4.3.4_build1/GNU
```

### Make a backup

`/work` is not backed up, `tar` everything safely on `/home`.  In
`/work/y07/y07/cse/libxc/4.3.4_build1/GNU` do

```bash
tar czf /home/y07/y07/cse/libxc/4.3.4_build1/GNU/copy_of_work.tgz .
chmod +r /home/y07/y07/cse/libxc/4.3.4_build1/GNU/copy_of_work.tgz
```

Restore using

```bash
mkdir -p /work/y07/y07/cse/libxc/4.3.4_build1/GNU
cd /work/y07/y07/cse/libxc/4.3.4_build1/GNU
tar xf /home/y07/y07/cse/libxc/4.3.4_build1/GNU/copy_of_work.tgz
chmod -R +rX /work/y07/y07/cse/libxc/4.3.4_build1/GNU
```

### Help improve these instructions

If you make changes that would update these instructions, please fork
this repository on GitHub, update the instructions and send a pull
request to incorporate them into this repository.

Notes
-----
