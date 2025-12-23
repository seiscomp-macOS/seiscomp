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

Please ask questions in the [forums](https://forum.seiscomp3.org) and
use appropriate topics to get help on usage or to discuss new features.

If you found a concrete issue in the codes or if you have code related
questions please use the Github issue tracker of the corresponding
repository,
e.g. [GitHub issue tracker of this repository](https://github.com/SeisComP/seiscomp/issues).

## Checkout the repositories with script clone_seiscomp-macos.sh

The SeisComP software collection is distributed among several repositories.
This repository only contains the build environment, the runtime framework
(seiscomp control script) and the documentation.

To checkout all seiscomp-macOS repositories to build a complete SeisComP distribution for macOS the following
script can be used.

Copy/paste the following content to file: `clone_seiscomp-macos.sh`

```
#!/bin/bash

repo_path="https://github.com/seiscomp-macOS"
target_dir=${WORKDIR}/seiscomp-macOS
WORKDIR=$(pwd)

echo "Creating build-dir"
build_dir=builds/${target_dir}
mkdir -p ${build_dir}

#------------------------------------------------------

echo "Cloning seiscomp-macOS from repository ${repo_path} into ${target_dir}"
git clone $repo_path/seiscomp.git $target_dir


echo "Cloning base components into ${target_dir}/src/base/"
#cd "$target_dir/src/base/"

/usr/bin/git -C $target_dir/src/base/ clone $repo_path/seedlink.git
/usr/bin/git -C $target_dir/src/base/ clone $repo_path/common.git
/usr/bin/git -C $target_dir/src/base/ clone $repo_path/main.git
/usr/bin/git -C $target_dir/src/base/ clone $repo_path/mainx.git
/usr/bin/git -C $target_dir/src/base/ clone $repo_path/extras.git

echo "Cloning external base components into ${target_dir}/src/base/"
/usr/bin/git -C $target_dir/src/base/ clone $repo_path/contrib-gns.git 
/usr/bin/git -C $target_dir/src/base/ clone $repo_path/contrib-ipgp.git 
/usr/bin/git -C $target_dir/src/base/ clone $repo_path/contrib-sed.git

echo "Cloning SeisComP MeRT repo into ${target_dir}/src/extras/"
/usr/bin/git -C $target_dir/src/extras/ clone $repo_path/scmert.git

cd "${WORKDIR}"

echo "If you want to use 'mu' command from https://fabioz.github.io/mu-repo/, call 'mu register --recursive'"
echo "To initialize the build, run 'make'."

```

To keep track of the state of each subrepository, [mu-repo](http://fabioz.github.io/mu-repo/)
is a recommended way.


## Build

### Linux Prerequisites (not required for macOS compilation)

The following packages should be installed to compile SeisComP:

- g++
- git
- cmake + cmake-gui
- libboost
- libxml2-dev
- flex
- libfl-dev
- libssl-dev
- crypto-dev
- libbson-dev
- python-dev (optional)
- python-numpy (optional)
- libqt4-dev (optional)
- qtbase5-dev (optional)
- libmysqlclient-dev (optional)
- libpq-dev (optional)
- libsqlite3-dev (optional)
- ncurses-dev (optional)

The Python development libraries are required if Python wrappers should be
compiled which is the default configuration. The development files must
match the used Python interpreter of the system. If the system uses Python3
then Python3 development files must be present in exactly the same version
as the used Python3 interpreter. The same holds for Python2.

Python-numpy is required if Numpy support is enable which is also
the default configuration.

### macOS Prerequisites

This will compile SeisComP natively on macOS for both Mac INTEL or Mac Silicon architectures (M1, M2, M3).
Latest SeisComP v7.x compiles on Mac INTEL and Mac Silicon with:

- macOS Sequoia 15.7.x or later (recommended for INTEL Macs since it comes with updated clang v17.x compiler)
- macOS Tahoe 26.x for Apple Silicon chips works too


- Install Xcode Development Tools

First we need to install the Development tools (Command Line Tools).
Note that the full Xcode Development Tools from "Mac App Store" is *not* required.

Open your "Terminal.app" and install Xcode command line tools with command:

`xcode-select --install`

- Install Homebrew for macOS

Install Homebrew 'brew' command with the following one-liner:

`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

On INTEL Mac the default Homebrew directory location is in: `/usr/local/`
On Apple Silicon Mac the default Homebrew directory location is in: `/opt/homebrew/opt/`

First install Homebrew's Python v3.x, which installs automatically NumPy.
Python 3.12 to 3.14 work and are recommended.

`brew install python@3`

If you need to install NumPy manually, use one of the following:

```
brew install numpy
pip3.13 install numpy
```

Note: If you need a more specific version of Python with NumPy, e.g. Python 3.10:
`brew install python@3.10`
`pip3.10 install numpy`


Continue installing macOS dependencies with:

```
brew install boost
brew install cmake
brew install coreutils # for GNU date - gdate
brew install gfortran
brew install mariadb #mysql can also be installed as an alternative
brew install ncurses
brew install openssl
brew install qt # installs version Qt6 (use qt@5 for Qt5)
```

Note: hdf5, flex (uses macOS system flex lib), fftw, mongo-c-driver@1 and swig are not required to compile.
They can be uninstalled (which also removes their dependencies with):
```
brew uninstall fftw
brew uninstall flex
brew uninstall hdf5
brew uninstall mongo-c-driver@1
```


After that check or update your .bashrc PATH, which needs Homebrew's specific paths:

The Homebrew shell path for INTEL Mac are:
- /usr/local/bin/ and
- /usr/local/sbin 

and for Apple Silicon Mac:
- /opt/homebrew/bin resp.
- /opt/homebrew/sbin/

should be added to your shell (e.g. for BASH = $HOME/.bashrc PATH)

Check your PATH from Terminal.app with:
`echo $PATH`

On INTEL Mac, your `~/.bashrc`should look like (note the `/usr/local/bin:/usr/local/sbin:` before `/bin/:/usr/bin`)

`PATH=/usr/local/bin/:/usr/local/sbin/:/bin:/usr/bin:/usr/sbin:/usr/X11/bin:$PATH`

On Apple Silicon Mac, your `~/.bashrc`should look like (note the `/opt/homebrew/bin:/opt/homebrew/sbin:` before `/bin/:/usr/bin`)

`PATH=/opt/homebrew/bin:/opt/homebrew/sbin:/bin:/usr/bin:/usr/sbin:$PATH`


### Clone the Github seiscomp-macOS repositories from https://github.com/seiscomp-macos/

Note that the script `clone_seiscomp-macos.sh` uses all the repositories from https://github.com/seiscomp-macos/ and not from https://github.com/seiscomp/
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
cmake -S seiscomp-macOS -B build-seiscomp -DCMAKE_INSTALL_PREFIX=${HOME}/seiscomp/
```

Note 1: if you need to use a specific Python version, e.g "Python 3.10" (don't forget to set your PATH accordingly):
`cmake -S seiscomp-macOS -B build-seiscomp -DCMAKE_INSTALL_PREFIX=${HOME}/seiscomp/ -DPython_VERSION_REQUIRED=3.10`

Compile SeisComP for macOS inside the `build-seiscomp` directory:

`make -j4`

If compilation was succesful, install seiscomp-macOS with command:

`make install`

It will install the binaries and libraries in ${HOME}/seiscomp (the MAKE_INSTALL_PREFIX).
Launch (test) e.g 'scmv' or 'scrttv' with command:

`${HOME}/seiscomp/bin/`


Note 1: After compilation the seedlink plugins directory contains compiled libraries e.g. libreftek.a libutil.a etc and objects .o
You should clean up the "seedlink/plugins" directory to be sure to recompile the latest versions (not necessary but should help compilation errors).
Also if you copy your "seiscomp" directory to another platform (Apple Silicon) or INTEL the compiled libraries are still there, so better do a `make clean`.

Just go to `seiscomp/src/base/seedlink/plugins` and do a `make clean`

```
cd seiscomp/src/base/seedlink/plugins
make clean
```

### Configure MySQL on macOS for better performance

Copy default MYSQL/MariaDB configuration file to /etc/my.cnf with command:

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

Then you forgot to install NumPy with `pip3` (NumPy site-package).
To fix, do this:

```
#brew install numpy
#pip3 install numpy
```

The NumPy site-package will then be installed to:

`/usr/local/lib/python3.<VERSION_NUMBER>/site-packages`

### Configuration

The SeisComP build system provides several build options which can be
controlled with a cmake gui or from the commandline
passing `-D[OPTION]=ON|OFF` to cmake.

In addition to standard cmake options such as `CMAKE_INSTALL_PREFIX`
the following global options are available:

|Option|Default|Description|
|------|-------|-----------|
|SC_GLOBAL_UNITTESTS|ON|Whether to build unittests or not. If enabled then use `ctest` in the build directory to run the unittests.|
|SC_GLOBAL_PYTHON_WRAPPER|ON|Build Python wrappers for the C++ libraries. You should not turn off this option unless you know exactly what you are doing.|
|SC_GLOBAL_PYTHON_WRAPPER_NUMPY|ON|Add Numpy support to Python wrappers. If enabled then all SeisComP arrays will provide a method `numpy()` which returns a Numpy array representation.|
|SC_ENABLE_CONTRIB|ON|Enable inclusion of external contributions into the build. This includes all directories in `src/extras`.|
|SC_GLOBAL_GUI|ON|Enables compilation of GUI components. This requires the Qt libraries to be installed. Either Qt4 or Qt5 are supported. The build will prefer Qt5 if found and will fallback to Qt4 if the Qt5 development libraries are not installed on the host system.|
|SC_GLOBAL_GUI_QT5|ON|If SC_GLOBAL_GUI is enabled then Qt5 support will be enabled if this option is active. Otherwise only Qt4 will be supported.|
|SC_DOC_GENERATE|OFF|Enable generation of documentation|
|SC_DOC_GENERATE_HTML|ON|Enable generation of HTML documentation|
|SC_DOC_GENERATE_MAN|ON|Enable generation of MAN pages|
|SC_DOC_GENERATE_PDF|OFF|Enable generation of PDF documentation|

### Compilation

1. Clone all required repositories (see above)
2. Run ```make```
3. Configure the build
4. Press 'c' as long as 'g' appears
5. Press 'g' to generate the Makefiles
6. Enter the build directory and run ```make```

### Installation

1. Enter the build directory and run ```make install```
   to install SeisComP

## Contributing improvements and bug fixes

Please consider [contributing](CONTRIBUTING.md) to the code.
