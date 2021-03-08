# zsh install instructions

Instructions to install zsh on ARCHER2 courtesy of Dr Andrew Brown (Queen's University Belfast).

## Install ncurses library


zsh requires the ncurses library. First download and extract the tarball
and set the compilation flags.

```
wget https://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.2.tar.gz
tar xvf ncurses-6.2.tar.gz
cd ncurses-6.2
export CXXFLAGS=' -fPIC'
export CPPFLAGS=' -fPIC'
export CFLAGS=' -fPIC'
```

And then configure for local install, build and install:

```
./configure --prefix=$HOME/.local --enable-shared
make
make install
```


## Install zsh

To install without documentation (the documentation requires icmake and yodl).
Download and extract the tarball as normal and in the configure step point at the local ncurses library in .local like so:

```
wget http://www.zsh.org/pub/zsh-5.8.tar.xz
tar -xvf zsh-5.8.tar.xz
cd zsh-5.8
./configure --prefix=$HOME/.local --enable-cppflags="-I<absolute path to home directory>.local/include" --enable-ldflags="-L<absolute path to home directory>.local/lib" --enable-shared
make
make install
```

##  Make zsh available to use

You can execute with
```
exec ~/.local/bin/zsh
```

or add the following to to .bashrc file to  make zsh execute automatically on login.

```
if [ "$PS1" ]; then
  if [[ $1 != "force" ]] ; then
    exec <path to home>/.local/bin/zsh
  fi
fi
```

## Initialise the module environment

In order to initialise the module environment correctly you must execute the following:

```
source /usr/local/Modules/init/zsh
```
or add it to your .zshrc file

