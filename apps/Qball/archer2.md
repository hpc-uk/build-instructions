# Qball build instructions

To compile Qball we use a GNU Autools procedure. 

## Build Qball

```
git clone https://github.com/LLNL/qball
cd qball
autoreconf -i
CC=cc CXX=CC FC=ftn ./configure --prefix=[YOUR_WORK_DIRECTORY]
make
make install
```
Further instructions can be found here:
https://github.com/LLNL/qball
