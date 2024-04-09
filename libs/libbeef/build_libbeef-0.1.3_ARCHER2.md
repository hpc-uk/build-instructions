
# Build libbeef 0.1.3 on ARCHER2

Download source code

```
git clone https://github.com/vossjo/libbeef.git
cd libbeef
```

Set-up module environment (you can exchange PrgEnv-cray or Prgenv-aocc if you want a library compatible with a different compiler)

```
module load PrgEnv-gnu
```

Configure and build
```
./configure CC=cc
make
```
