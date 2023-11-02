# SeisComP

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

## Checkout the repositories

The SeisComP software collection is distributed among several repositories.
This repository only contains the build environment, the runtime framework
(seiscomp control script) and the documentation.

To checkout all repositories to build a complete SeisComP distribution the
following script can be used:

```sh
#!/bin/bash

if [ $# -eq 0 ]
then
    echo "$0 <target-directory>"
    exit 1
fi

target_dir=$1
repo_path=https://github.com/SeisComP

echo "Cloning base repository into $target_dir"
git clone $repo_path/seiscomp.git $target_dir

echo "Cloning base components"
cd $target_dir/src/base
git clone $repo_path/seedlink.git
git clone $repo_path/common.git
git clone $repo_path/main.git
git clone $repo_path/mainx.git
git clone $repo_path/extras.git

echo "Cloning external base components"
git clone $repo_path/contrib-gns.git
git clone $repo_path/contrib-ipgp.git
git clone https://github.com/swiss-seismological-service/sed-SeisComP-contributions.git contrib-sed

echo "Done"

cd ../../

echo "If you want to use 'mu', call 'mu register --recursive'"
echo "To initialize the build, run 'make'."
```

To keep track of the state of each subrepository, [mu-repo](http://fabioz.github.io/mu-repo/)
is a recommended way.


## Build

### Linux Prerequisites

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

This will compile SeisComP natively on macOS for Mac INTEL or Mac Silicon.
Tested on macOS Ventura 13.6.1 on Mac INTEL and Mac Silicon architectures (M1, M2).
It should also work on the latest macOS Sonoma.

- Install Xcode Development Tools

Note that the full Xcode Development Tools from "Mac App Store" is *not* required.
Just install the Dev Tools from the Terminal instead:

Open your Terminal.app and install XCode command line tools with command:

`xcode-select --install`

- Install Homebrew for macOS

On INTEL Mac the default Homebrew directory is located in: `/usr/local/`
On Apple Silicon Mac the default Homebrew directory is located in `/opt/local/homebrew/`

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

```
brew install boost #installs libboost > 1.83
brew install cmake
brew install fftw #installs fftw v3
brew install flex
brew install gcc #needed for gfortran
brew install hdf5
brew install mysql #mariadb can also be installed as an alternative
brew install ncurses
brew install numpy
brew install openssl #installs OpenSSL@3
brew install python3
brew install qt5
brew install swig
```

Note: If you need a more specific version of python, e.g:

`brew install python@3.10`

After that check or update your PATH to include Homebrew paths:

The Homebrew shell path for INTEL Mac /usr/local/bin/ and /usr/local/sbin and /opt/homebrew/bin resp. /opt/homebrew/sbin/
should be in your PATH

`echo $PATH`

e.g. for INTEL Mac:

```
/usr/local/bin:/usr/local/sbin:/bin:/usr/bin:/usr/sbin:
```

e.g. for Silicon Mac:

```
/opt/homebrew/bin:/usr/local/sbin:/bin:/usr/bin:/usr/sbin:
```

On macOS compile with, e.g: "seiscomp" was git-cloned inside ~/Downloads/seiscomp-macOS:

```
cd seiscomp-macOS
mkdir build-seiscomp
cd build-seiscomp
cmake -DCMAKE_INSTALL_PREFIX=${HOME}/seiscomp ../seiscomp
```

If you need to compile with a specific Python version, e.g "Python 3.10" (don't forget to set your PATH accordingly):
`cmake -DCMAKE_INSTALL_PREFIX=${HOME}/seiscomp ../seiscomp/ -DPython_VERSION_REQUIRED=3.10`

Compile SeisComP for macOS:
`make -j4`

Install with command:
`make install`

If compilation was succesful it will install the binaries and libraries in ${HOME}/seiscomp (the MAKE_INSTALL_PREFIX).
Launch (test) e.g 'scmv' or 'scrttv' with command:

`/Users/<YOUR_USER_NAME>/seiscomp/bin/`


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
