# SeisComP for macOS

Welcome to the macOS port of SeisComP, a seismological software for data acquisition, processing, distribution and interactive analysis.

Please note that this is a forked repository of SeisComP developed by the GEOFON Program at Helmholtz Centre Potsdam GFZ German Research Centre for Geosciences and gempa GmbH,
so no support is provided from GFZ or gempa GmbH.

Check official site:
https://www.seiscomp.de

Original Github repository:
https://github.com/seiscomp/

## SeisComP for macOS compilation instructions

## About

SeisComP is a seismological software for data acquisition, processing,
distribution and interactive analysis that has been developed by the
GEOFON Program at  Helmholtz Centre Potsdam, GFZ German Research Centre
for Geosciences and gempa GmbH.

## License

SeisComP is primarily released under the AGPL 3.0. Please check the [license agreement](doc/base/license.rst).

## Asking Questions

Note: If you have a specific issue wit "seiscomp-macOS" please post your issue to
[seiscomp-macOS Issues](https://github.com/seiscomp-macOS/seiscomp/issues)
and not in the official forum of "seiscomp".

For specific "seiscomp" questions:

Please ask questions in the [forums](https://forum.seiscomp3.org) and
use appropriate topics to get help on usage or to discuss new features.

If you found a concrete issue in the codes or if you have code related
questions please use the Github issue tracker of the corresponding
repository,
e.g. [GitHub issue tracker of this repository](https://github.com/SeisComP/seiscomp/issues).

## Checkout the repositories with script: clone_seiscomp-macos.sh

The SeisComP software collection is distributed among several repositories.
This repository only contains the build environment, the runtime framework
(seiscomp control script) and the documentation.

To checkout all repositories to build a complete SeisComP distribution for macOS the following
script can be used.

Copy/paste the following content to file: `clone_seiscomp-macos.sh`

```
#!/bin/bash

target_dir="seiscomp-macOS"
repo_path=https://github.com/seiscomp-macos/

WORKDIR=$(pwd)

echo "Cloning seiscomp base repository into $target_dir"
git clone $repo_path/seiscomp.git $target_dir

echo "Cloning base components"
cd $target_dir/src/base
git clone $repo_path/seedlink.git
git clone $repo_path/common.git
git clone $repo_path/main.git
git clone $repo_path/extras.git

echo "Cloning external base components"
git clone $repo_path/contrib-gns.git
git clone $repo_path/contrib-ipgp.git
git clone $repo_path/contrib-sed.git

echo "Cloning SeisComP MeRT repo into ${target_dir}/src/base/extras/"
/bin/cd "${target_dir}/src/extras/" 
git clone $repo_path/scmert.git

echo "Done cloning seiscomp-macOS"

cd ../../
```

To keep track of the state of each subrepository, [mu-repo](http://fabioz.github.io/mu-repo/)
is a recommended way.


## Build

### macOS Prerequisites

These instructions will let you compile SeisComP natively on macOS for both Mac INTEL or Mac Silicon architectures (M1, M2, M3).
Tested on macOS Ventura 13.x and Sonoma 14.x on Mac INTEL and Mac Silicon.

**Note**: The Bash-Shell (bash) will be used instead of macOS default Z Shell (zsh),
so we will use .bashrc to edit the PATH.

The Python development libraries are required if Python wrappers should be
compiled which is the default configuration. The development files must
match the used Python interpreter of the system. If the system uses Python3
then Python3 development files must be present in exactly the same version
as the used Python3 interpreter. The same holds for Python2.

Python-numpy is required if Numpy support is enable which is also
the default configuration.


- Install Xcode Development Tools

First we need to install the Development tools (Command Line Tools).
Note that the full Xcode Development Tools from "Mac App Store" is *not* required.

Open your "Terminal.app" and install Xcode command line tools with command:

`xcode-select --install`

- Install Homebrew for macOS

Install Homebrew 'brew' command with the following one-liner:

`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

> On INTEL Mac the default Homebrew directory location is in: `/usr/local/`
>
> On Apple Silicon Mac the default Homebrew directory location is in: `/opt/homebrew/opt/`

**Python 3.11 is recommended since Python 3.12 has compatibility issues with seedlink and other Python modules.**
First install Python v3.11 with NumPy, which needs to be installed as a site-package with pip3.

```
brew install python@3.11
brew install numpy
pip3.11 install numpy
```

**IMPORTANT for Python installation **:

Since beginning of March 2024, Homebrew installs Python 3.12 as the default Python3 version.

However SeisComP's Python modules prefer Python 3.11, so if you don't set the Python 3.11 PATH
correctly the SeisComP Python scripts will be executed with Python 3.12 and it will crash
(since some Python modules were compiled with Python 3.11).

We need to add **Python 3.11** before the /usr/local/bin resp. /opt/homebrew/opt/bin/ to Bash PATH:

Edit .bashrc and add **python@3.11** binary location, something like:

> On INTEL Mac, your `~/.bashrc`should look like:
>
`export PATH="/usr/local/opt/python@3.11/libexec/bin:/usr/local/bin/:/usr/local/sbin/:/bin:/usr/bin:/usr/sbin:/usr/X11/bin:$PATH"`

Note that the binary location Python3.11 is before `/bin/:/usr/bin`)


> On Apple Silicon Mac, your `~/.bashrc`should look like: 
>
`export PATH="/opt/homebrew/opt/python@3.11/libexec/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/bin:/usr/bin:/usr/sbin:$PATH"`

Note that the binary location Python3.11 is before `/bin/:/usr/bin`)

**NOTE for Boost installation **:

Latest upstream seiscomp is compatible with Boost v1.86, no need to install older Boost 1.76 anymore on macOS.

### Continue installing macOS dependencies with:

```
brew install boost
brew install cmake
brew install fftw 
brew install flex
brew install gfortran
brew install hdf5
brew install mysql #mariadb can also be installed as an alternative
brew install ncurses
brew install openssl@3
brew install qt@5
brew install swig
```


### Clone the Github repositories from https://github.com/seiscomp-macos/

Note that the script `clone_seiscomp-macos.sh` uses the repo from https://github.com/seiscomp-macos/ and not from https://github.com/seiscomp

Use the script  `clone_seiscomp-macos.sh` to git-clone all the repos.

Here's how to proceed:

1. Create directory seiscomp-macos inside your Downloads directory:

```
mkdir ~/Downloads/seiscomp-macos
cd ~/Downloads/seiscomp-macos
```
Move the script `clone_seiscomp-macos.sh` to `~/Downloads/seiscomp-macos`

Change script to executable - do this once:

`chmod u+x clone_seiscomp-macos.sh`

Now clone the seiscomp-macOS repos inside `~/Downloads/seiscomp-macos`
 `./clone_seiscomp-macos.sh`
 
After this you will see a the source-code directory named: `seiscomp` inside `~/Downloads/seiscomp-macos`

### Compile seiscomp on macOS 

After succesful git-cloning with the script `clone_seiscomp-macos.sh`, compile SeisComP on your Mac with command: `cmake`

Still inside `~/Downloads/seiscomp-macos` do the following:

```
mkdir build-seiscomp
cd build-seiscomp
cmake -DCMAKE_INSTALL_PREFIX=${HOME}/seiscomp ../seiscomp
```

Note 1: if you need to use a specific Python version, e.g "Python 3.10" (don't forget to set your PATH accordingly):

`cmake -DCMAKE_INSTALL_PREFIX=${HOME}/seiscomp ../seiscomp/ -DPython_VERSION_REQUIRED=3.10`

Compile SeisComP for macOS in the `build-seiscomp` directory:

`make -j4`

Install with command:

`make install`

If compilation was succesful the installed  binaries will be in `${HOME}/seiscomp` (the choosed `CMAKE_INSTALL_PREFIX`).

Launch (test) e.g 'scmv' or 'scrttv' with command:

`/Users/<YOUR_USER_NAME>/seiscomp/bin/scmv`

`/Users/<YOUR_USER_NAME>/seiscomp/bin/scrttv`


### Cleanup Seedlink plugins directory

Note 1: Not required but after compilation, the seedlink plugins directory contains compiled libraries e.g. libreftek.a libutil.a etc.

You should clean up the "seedlink/plugins" directory to be sure to recompile the latest versions (not required but could help to avoid compilation errors).

Also if you copy your "seiscomp" directory to another Mac platform, e.g. INTEL to Apple Silicon, the compiled libraries for the specific platforms are still there,
and could lead to crashes, so better clean up with a `make clean`.

Just go to `seiscomp/src/base/seedlink/plugins` and do a `make clean`

```
cd seiscomp/src/base/seedlink/plugins
make clean
```

### Configure MySQL on macOS for better performance

Copy default MYSQL configuration file to /etc/my.cnf with command:

`sudo cp $(brew --prefix mysql)/support-files/my-default.cnf /etc/my.cnf`

For better performance with the MySQL database, adjust the following parameters in /etc/my.cnf
If you have more than 8GB of RAM, increase `innodb_buffer_pool_size` (default is 128MB):
 
```
innodb_buffer_pool_size = 8G
innodb-buffer-pool-instances=16
innodb_flush_log_at_trx_commit = 2
```

### macOS Troubleshooting

If you get the following error when compiling:

`"_Python3_NumPy_INCLUDE_DIR-NOTFOUND"`

Then you forgot to install NumPy with `pip3.11` (NumPy site-package).
To fix, do this:

```
#brew install numpy
#pip3.11 install numpy
```

The NumPy site-package will then be installed to:

`/usr/local/lib/python3.11/site-packages`

## Contributing improvements and bug fixes

Please consider [contributing](CONTRIBUTING.md) to the code.
