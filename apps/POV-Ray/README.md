# POV-ray build instructions for Cirrus with GCC


## Download POV-ray-3.7
```
git clone --single-branch --branch 3.7-stable https://github.com/POV-Ray/povray.git
cd povray/unix
```

## Set GNU environment

```
module load gcc
module load boost/1.73.0
module load zlib
module load libpng

```

## Prebuild 

```
./prebuild.sh
cd ../
```

## Configure 

```
./configure --prefix=<directory to install to> COMPILED_BY=<user email address> --with-boost=/lustre/sw/boost/1.73.0 --with-boost-libdir=/lustre/sw/boost/1.73.0/lib
```

## Compile

```
make check install
```

The povray executable is then created in `unix/povray`


## Sample test

```
cd unix
./povray icons/source/icon.pov
```
