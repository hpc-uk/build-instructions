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

assert_equal(fpos64(0.5**(1022 + 52), unique=False, precision=1074),
                    "0.00000000000000000000000000000000000000000000000000000000"
                    "0000000000000000000000000000000000000000000000000000000000"
                    "0000000000000000000000000000000000000000000000000000000000"
                    "0000000000000000000000000000000000000000000000000000000000"
                    "0000000000000000000000000000000000000000000000000000000000"
                    "0000000000000000000000000000000000049406564584124654417656"
                    "8792868221372365059802614324764425585682500675507270208751"
                    "8652998363616359923797965646954457177309266567103559397963"
                    "9877479601078187812630071319031140452784581716784898210368"
                    "8718636056998730723050006387409153564984387312473397273169"
                    "6151400317153853980741262385655911710266585566867681870395"
                    "6031062493194527159149245532930545654440112748012970999954"
                    "1931989409080416563324524757147869014726780159355238611550"
                    "1348035264934720193790268107107491703332226844753335720832"
                    "4319360923828934583680601060115061698097530783422773183292"
                    "4790498252473077637592724787465608477820373446969953364701"
                    "7972677717585125660551199131504891101451037862738167250955"
                    "8373897335989936648099411642057026370902792427675445652290"
                    "87538682506419718265533447265625")
E       OverflowError: (34, 'Numerical result out of range')

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
