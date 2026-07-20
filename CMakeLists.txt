CMAKE_MINIMUM_REQUIRED(VERSION 3.30.0 FATAL_ERROR)
CMAKE_POLICY(SET CMP0003 NEW)
CMAKE_POLICY(SET CMP0005 NEW)

# Allows using FindPythonInterp and FindPythonLibs with cmake >= 3.28
IF ("${CMAKE_VERSION}" VERSION_GREATER_EQUAL 3.28)
	CMAKE_POLICY(SET CMP0148 OLD)
ENDIF ("${CMAKE_VERSION}" VERSION_GREATER_EQUAL 3.28)

# Allows using certain add_custom_command keywords with cmake >= 3.31
IF ("${CMAKE_VERSION}" VERSION_GREATER_EQUAL 3.31)
	CMAKE_POLICY(SET CMP0175 OLD)
ENDIF ("${CMAKE_VERSION}" VERSION_GREATER_EQUAL 3.31)

IF(APPLE)
    # First check if Xcode.app or CommandLineTools are installed
    # 1. Fast Path: Check the default standalone location
    IF(NOT EXISTS "/Library/Developer/CommandLineTools")
        # Query the system for full Xcode or custom paths
        EXECUTE_PROCESS(
            COMMAND xcode-select -p
            RESULT_VARIABLE COMMANDLINETOOLS_RESULT
            OUTPUT_QUIET
            ERROR_QUIET
        )
        IF(NOT COMMANDLINETOOLS_RESULT EQUAL 0)
            MESSAGE(FATAL_ERROR "Xcode Command Line Tools not found. Install with 'xcode-select --install' in your terminal.")
        ENDIF()
    ENDIF()
    
   IF(NOT CMAKE_OSX_ARCHITECTURES)
        # CMAKE_HOST_SYSTEM_PROCESSOR isn't populated until PROJECT() runs
        # so query the OS directly instead.
        EXECUTE_PROCESS(
            COMMAND uname -m
            OUTPUT_VARIABLE TARGET_ARCH
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    ELSE()
        LIST(GET CMAKE_OSX_ARCHITECTURES 0 TARGET_ARCH)
    ENDIF()
    
    SET(CMAKE_OSX_ARCHITECTURES "${TARGET_ARCH}" CACHE STRING "BUILD ARCHITECTURE" FORCE)

    IF(TARGET_ARCH MATCHES "^arm64")
        MESSAGE(STATUS "SINGLE-ARCH BUILD: APPLE SILICON (arm64)")
        SET(CMAKE_OSX_DEPLOYMENT_TARGET "15.0" CACHE STRING "Minimum macOS version for arm64")
        IF(EXISTS "/opt/homebrew")
            LIST(APPEND CMAKE_PREFIX_PATH "/opt/homebrew")
            LIST(APPEND CMAKE_IGNORE_PREFIX_PATH "/usr/local")
        ELSE()
            MESSAGE(FATAL_ERROR "Homebrew for macOS not installed! Please follow the installation instructions from: https://brew.sh")
        ENDIF()
    ELSEIF(TARGET_ARCH MATCHES "^x86_64")
        MESSAGE(STATUS "SINGLE-ARCH BUILD: INTEL MAC (x86_64)")
        SET(CMAKE_OSX_DEPLOYMENT_TARGET "15.0" CACHE STRING "Minimum macOS version for x86_64")
        IF(EXISTS "/usr/local/Cellar")        
            LIST(APPEND CMAKE_PREFIX_PATH "/usr/local/")
            LIST(APPEND CMAKE_IGNORE_PREFIX_PATH "/opt/homebrew")
        ELSE()
            MESSAGE(FATAL_ERROR "Homebrew for macOS not installed! Please follow the installation instructions from: https://brew.sh")
        ENDIF()
    ELSE()
        MESSAGE(FATAL_ERROR "macOS: Unexpected/Unsupported Target Architecture: '${TARGET_ARCH}'")
    ENDIF()

    SET(CMAKE_C_STANDARD 17)
    SET(CMAKE_C_STANDARD_REQUIRED ON)
    SET(CMAKE_CXX_STANDARD 17)
    SET(CMAKE_CXX_STANDARD_REQUIRED ON)

    # On macOS try to find (Homebrew) frameworks after system's standard libraries or headers. Default is FIRST.
    SET(CMAKE_FIND_FRAMEWORK LAST)
    
    # Suppress QT6 OpenGL linking warnings 
    SET(OPENGL_INCLUDE_DIR "/System/Library/Frameworks/OpenGL.framework/Headers" CACHE PATH "" FORCE)
    SET(OPENGL_gl_LIBRARY "/System/Library/Frameworks/OpenGL.framework" CACHE FILEPATH "" FORCE)
    SET(OPENGL_GLU_INCLUDE_DIR "/System/Library/Frameworks/OpenGL.framework/Headers" CACHE PATH "" FORCE)
    SET(OPENGL_glu_LIBRARY "/System/Library/Frameworks/OpenGL.framework" CACHE FILEPATH "" FORCE)

    # Set RPATH for macOS - adds run-time search path for dynamic linking to libraries when building the applications
    # Avoids error "dyld: Library not loaded" when launching a compiled program
    SET(CMAKE_MACOSX_RPATH ON)
     
    # When compiling don't use the install RPATH already, but later on when installing
    SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
	
    # Add the automatically determined parts of the RPATH
    # which point to directories outside the build tree to the install RPATH
    SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
    
    # Add /lib to CMAKE_INSTALL_NAME_DIR or it fails to launch apps (error: .dylib not found)
	SET(CMAKE_INSTALL_NAME_DIR "${CMAKE_INSTALL_PREFIX}/lib")
	
    ADD_COMPILE_DEFINITIONS(
        SHARED_LIBRARY_SUFFIX="${CMAKE_SHARED_LIBRARY_SUFFIX}"
        SHARED_MODULE_SUFFIX="${CMAKE_SHARED_MODULE_SUFFIX}"
    )
    
ENDIF()

PROJECT(SeisComP)

# Global options (see below):
# - SC_GLOBAL_PYTHON_WRAPPER
# - SC_GLOBAL_PYTHON_WRAPPER_NUMPY

#SET(CMAKE_DEBUG_POSTFIX _d)
SET(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/lib)
SET(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR}/bin)
SET(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
SET(CMAKEDEFINE "#cmakedefine")

#OPTION(SHARED_LIBRARIES "Build shared libraries" ON)
SET(SHARED_LIBRARIES 1)
ADD_DEFINITIONS(-DSC_ALL_SHARED)
IF (WIN32)
	ADD_DEFINITIONS(-D_USE_MATH_DEFINES)
	ADD_DEFINITIONS(-DNOMINMAX)
ENDIF (WIN32)

# Find needed packages
IF(APPLE)
    # Disable SeisComP custom CMake config files from CMAKE_MODULE_PATH
    # since recent cmake has them built-in (e.g. boost, numpy, ncurses, openssl)
    LIST(REMOVE_ITEM CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")
    # Explicitly include only some required custom cmake config files
    INCLUDE("${PROJECT_SOURCE_DIR}/cmake/flex.cmake")
    INCLUDE("${PROJECT_SOURCE_DIR}/cmake/FindMySQL.cmake")
    INCLUDE("${PROJECT_SOURCE_DIR}/cmake/SeisComP.cmake")
    INCLUDE("${PROJECT_SOURCE_DIR}/cmake/FindSPREAD.cmake")
ENDIF()

FIND_PACKAGE(LibXml2 REQUIRED)

OPTION(SC_GLOBAL_UNITTESTS "Enable unit tests" ON)
OPTION(SC_GLOBAL_PYTHON_WRAPPER "Create Python 3 wrapper" ON)
OPTION(SC_GLOBAL_PYTHON_WRAPPER_NUMPY "Add Numpy support for Python 3 wrapper" ON)
OPTION(SC_ENABLE_CONTRIB "Enables descending into the contrib directory" ON)

IF(NOT APPLE)
    # Modern GCC (>= 5.1) on old systems with libraries compiled with ABI version 0.
    # see https://gcc.gnu.org/onlinedocs/libstdc++/manual/using_dual_abi.html
    OPTION(FORCE_CXX11_ABI_0 "Option description" OFF)

	IF ("${CMAKE_VERSION}" VERSION_LESS 3.12)
	    SET(PythonInterp_FIND_VERSION 3)
	    SET(PythonInterp_FIND_VERSION_MAJOR 3)
	    SET(PythonInterp_FIND_VERSION_EXACT 0)
	    FIND_PACKAGE(PythonInterp)
        ELSE ("${CMAKE_VERSION}" VERSION_LESS 3.12)
	    FIND_PACKAGE(Python 3 REQUIRED COMPONENTS Interpreter NumPy Development)
	    IF (NOT PYTHON_EXECUTABLE)
		    SET(PYTHON_EXECUTABLE "${Python_EXECUTABLE}")
	    ENDIF ()
    ENDIF ("${CMAKE_VERSION}" VERSION_LESS 3.12)
    EXECUTE_PROCESS(
        COMMAND ${PYTHON_EXECUTABLE} -c "import sys;print(sys.version.split()[0])"
        OUTPUT_VARIABLE PYTHON_VERSION
    )
    STRING(STRIP "${PYTHON_VERSION}" PYTHON_VERSION)
    MESSAGE(STATUS "Python exec/version: ${PYTHON_EXECUTABLE} ${PYTHON_VERSION}")
ENDIF()

IF(APPLE)
    # IMPORTANT: Set Python3_FIND_STRATEGY to LOCATION so it will search for the given version number first
    # if Python3_ROOT_DIR is set.
    # helps to set the python version which is desired instead of the latest Python3 version (e.g. Python 3.12)
    SET(Python3_FIND_STRATEGY LOCATION)
    
    # On macOS if user has set exact Python_VERSION_REQUIRED var with e.g: -DPython_VERSION_REQUIRED=3.10
    IF(Python_VERSION_REQUIRED)
        # macOS: check Homebrew version of Python_VERSION_REQUIRED:
        EXECUTE_PROCESS(
            COMMAND brew --prefix python@${Python_VERSION_REQUIRED}
                RESULT_VARIABLE BREW_PYTHON
                OUTPUT_VARIABLE BREW_PYTHON_PREFIX
                OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    ELSE()
        # macOS: check Homebrew version of Python to be 3 by default, so finding most recent installed:
        EXECUTE_PROCESS(
            COMMAND  brew --prefix python@3
                RESULT_VARIABLE BREW_PYTHON
                OUTPUT_VARIABLE BREW_PYTHON_PREFIX
                OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    ENDIF()

    # If the desired python version (or the most recent if no version given) is installed with Homebrew, then continue, otherwise throw error
    IF(BREW_PYTHON EQUAL 0 AND EXISTS "${BREW_PYTHON_PREFIX}")
        
        # First search for python to consider
        IF(Python_VERSION_REQUIRED)	
            MESSAGE(STATUS "FIRST SEARCH: Finding Python@${Python_VERSION_REQUIRED} installed by Homebrew")
            FIND_PACKAGE(Python3 ${Python_VERSION_REQUIRED} EXACT REQUIRED COMPONENTS Interpreter Development)
            MESSAGE(STATUS "-----")
        ELSE()
            MESSAGE(STATUS "FIRST SEARCH: Finding Python3 installed by Homebrew")
            FIND_PACKAGE(Python3 REQUIRED COMPONENTS Interpreter Development)
            MESSAGE(STATUS "-----")
        ENDIF()

        # Define the PYTHON3_VIRTUAL_ENVIRONMENT
        SET(PYTHON3_VIRTUAL_ENVIRONMENT_PATH "${CMAKE_INSTALL_PREFIX}/.pyenvSC")

        # Check if virtual environment exists & if not, install it and install numpy/Twisted/python-dateutil in it
        EXECUTE_PROCESS(
            COMMAND  ${PYTHON3_VIRTUAL_ENVIRONMENT_PATH}/bin/python --version
                RESULT_VARIABLE VENV_PYTHON
                OUTPUT_VARIABLE VENV_PYTHON_VERSION_STRING
                OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        IF(VENV_PYTHON EQUAL 0 AND EXISTS "${PYTHON3_VIRTUAL_ENVIRONMENT_PATH}")
            MESSAGE(STATUS "VIRTUAL ENVIRONMENT: Found Python venv of version ${VENV_PYTHON_VERSION_STRING} installed in ${PYTHON3_VIRTUAL_ENVIRONMENT_PATH}")
            MESSAGE(STATUS "USING THIS VIRTUAL ENVIRONMENT FOR COMPILATION")
            MESSAGE(STATUS "-----")
        ELSE()
            MESSAGE(STATUS "VIRTUAL ENVIRONMENT: Installing Python3 venv in ${PYTHON3_VIRTUAL_ENVIRONMENT_PATH}, including numpy/Twisted/python-dateutil packages")	
            EXECUTE_PROCESS(COMMAND ${Python3_EXECUTABLE} -m venv ${PYTHON3_VIRTUAL_ENVIRONMENT_PATH})
            EXECUTE_PROCESS(COMMAND ${PYTHON3_VIRTUAL_ENVIRONMENT_PATH}/bin/pip3 install numpy Twisted python-dateutil)
            MESSAGE(STATUS "-----")
        ENDIF()

        # Set Python3_ROOT_DIR to virtual environment, set to find virtual environment first and unset Python3_EXECUTABLE before finding again the package
        SET(Python3_ROOT_DIR "${PYTHON3_VIRTUAL_ENVIRONMENT_PATH}")
        SET(ENV{VIRTUAL_ENV} "${PYTHON3_VIRTUAL_ENVIRONMENT_PATH}")
        SET(Python3_FIND_VIRTUALENV FIRST)
        UNSET(Python3_EXECUTABLE)

        # Look again for Python3 package with virtual environment set up
        IF(Python_VERSION_REQUIRED)	
            #MESSAGE(STATUS "Found Python@${Python_VERSION_REQUIRED} installed by Homebrew at ${BREW_PYTHON_PREFIX} with venv at ${PYTHON3_VIRTUAL_ENVIRONMENT_PATH}")
            FIND_PACKAGE(Python3 ${Python_VERSION_REQUIRED} EXACT REQUIRED COMPONENTS Interpreter Development)
        ELSE()
            #MESSAGE(STATUS "Found Python3 installed by Homebrew at ${BREW_PYTHON_PREFIX} with venv at ${PYTHON3_VIRTUAL_ENVIRONMENT_PATH}")
            FIND_PACKAGE(Python3 REQUIRED COMPONENTS Interpreter Development)
        ENDIF()

    ELSE()
        MESSAGE(STATUS "Homebrew Python3 not found.")
        IF(Python_VERSION_REQUIRED)		
            MESSAGE(FATAL_ERROR "Install with: brew install python@${Python_VERSION_REQUIRED}")
        ELSE()
            MESSAGE(FATAL_ERROR "Install with: brew install python@3")
        ENDIF()	
    ENDIF()

    SET(PYTHON_EXECUTABLE ${Python3_EXECUTABLE})
    SET(PYTHON_LIBRARIES ${Python3_LIBRARIES})
    SET(PYTHON_INCLUDE_DIR ${Python3_INCLUDE_DIRS})
    SET(PYTHON_INCLUDE_PATH ${Python3_INCLUDE_DIRS})
    MESSAGE(STATUS "-----")
    EXECUTE_PROCESS(
        COMMAND ${PYTHON_EXECUTABLE} -c "import sys;print(sys.version.split()[0])"
        OUTPUT_VARIABLE PYTHON_VERSION
    )
    STRING(STRIP "${PYTHON_VERSION}" PYTHON_VERSION)
    MESSAGE(STATUS "PYTHON EXECUTABLE used: ${PYTHON_EXECUTABLE} ${PYTHON_VERSION}")
    MESSAGE(STATUS "PYTHON_LIBRARIES used: 	    ${PYTHON_LIBRARIES}")
    MESSAGE(STATUS "PYTHON_INCLUDE_PATH used:   ${PYTHON_INCLUDE_PATH}")
    MESSAGE(STATUS "PYTHON_INCLUDE_DIR used:	${PYTHON_INCLUDE_DIR}")
    MESSAGE(STATUS "-----")
ENDIF()

IF(SC_GLOBAL_PYTHON_WRAPPER_NUMPY)
	IF(APPLE)
	    # macOS: find specific Python_Version version of NumPy
        IF(Python_VERSION_REQUIRED)	
			# Check for numpy installation in virtual environment for SeisComP
			EXECUTE_PROCESS(COMMAND ${PYTHON3_VIRTUAL_ENVIRONMENT_PATH}/bin/pip${Python_VERSION_REQUIRED} show numpy
	    	RESULT_VARIABLE EXIT_CODE
	    	    OUTPUT_QUIET
	    	)
		ELSE()
			# Check for numpy installation in virtual environment for SeisComP
			EXECUTE_PROCESS(COMMAND ${PYTHON3_VIRTUAL_ENVIRONMENT_PATH}/bin/pip3 show numpy
			RESULT_VARIABLE EXIT_CODE
				OUTPUT_QUIET
			)
		ENDIF()
		
		IF (${EXIT_CODE} EQUAL 0)
			IF(Python_VERSION_REQUIRED)	
				FIND_PACKAGE(Python3 ${Python_VERSION_REQUIRED} EXACT COMPONENTS NumPy)
				SET(PYTHON_NUMPY_INCLUDE_DIR ${Python3_NumPy_INCLUDE_DIRS})
			ELSE()
				FIND_PACKAGE(Python3 COMPONENTS NumPy)
				SET(PYTHON_NUMPY_INCLUDE_DIR ${Python3_NumPy_INCLUDE_DIRS})
			ENDIF()
			MESSAGE(STATUS "NumPy version found: ${Python3_NumPy_VERSION}")
			MESSAGE(STATUS "-----")
		ELSE()
			MESSAGE(FATAL_ERROR "NumPy not installed. Install with: brew install python; brew install numpy")	
		ENDIF()
	ELSE()
		FIND_PACKAGE(Numpy)
	    IF (NOT PYTHON_NUMPY_INCLUDE_DIR AND "${CMAKE_VERSION}" VERSION_GREATER_EQUAL 3.12)
		    FIND_PACKAGE(Python 3 REQUIRED COMPONENTS Interpreter NumPy Development)
		    SET(PYTHON_NUMPY_INCLUDE_DIR "${Python_NumPy_INCLUDE_DIRS}")
	    ENDIF()
	ENDIF()
ENDIF()

# Disable the depreacted Pythonlibs & PythonInterp on macOS
IF(NOT APPLE)
    FIND_PACKAGE(PythonLibs REQUIRED)
    FIND_PACKAGE(PythonInterp REQUIRED)
ENDIF()

SET(PYTHON_LIBRARY_SUFFIX /python)
SET(PYTHON_LIBRARY_PATH lib${PYTHON_LIBRARY_SUFFIX})

OPTION(SC_GLOBAL_GUI "Build graphical user interfaces (requires Qt5 or Qt6)" ON)
OPTION(SC_GLOBAL_GUI_QT5 "Build graphical user interfaces with Qt5" ON)
OPTION(SC_GLOBAL_GUI_QT6 "Build graphical user interfaces with Qt6" OFF)

IF(SC_GLOBAL_GUI)
	IF((NOT SC_GLOBAL_GUI_QT5) AND (NOT SC_GLOBAL_GUI_QT6))
		MESSAGE(FATAL_ERROR "Either Qt5 or Qt6 must be enabled, other versions are not supported")
	ENDIF()
	IF((SC_GLOBAL_GUI_QT5) AND (SC_GLOBAL_GUI_QT6))
		MESSAGE(FATAL_ERROR "Qt5 and Qt6 are enabled, please decide for one of them")
	ENDIF()
	IF(SC_GLOBAL_GUI_QT5)
		FIND_PACKAGE(Qt5 REQUIRED COMPONENTS Core Widgets)
		MESSAGE(STATUS "Use Qt5")
	ENDIF()
	IF(SC_GLOBAL_GUI_QT6)
		FIND_PACKAGE(Qt6 REQUIRED COMPONENTS Core Widgets)
		MESSAGE(STATUS "Use Qt6")
	ENDIF()
ENDIF()

INCLUDE(AddFileDependencies)
INCLUDE(SeisComP)

SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "")
SET(CPACK_PACKAGE_VENDOR "seiscomp-devel@gfz-potsdam.de")
SET(CPACK_PACKAGE_VERSION_NAME  "Potsdam")
SET(CPACK_PACKAGE_VERSION_MAJOR "7")
SET(CPACK_PACKAGE_VERSION_MINOR "0")
SET(CPACK_PACKAGE_VERSION_PATCH "0")
#SET(CPACK_STRIP_FILES "bin/*")
SET(CPACK_SOURCE_STRIP_FILES "")
#SET(CPACK_PACKAGE_EXECUTABLES "bin/*")
SET(CPACK_PACKAGE_FILE_NAME "seiscomp-${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}")
INCLUDE(CPack)

SET(PROJECT_CONFIG_DIR etc)
SET(PROJECT_SHARE_DIR share)
SET(PROJECT_API_H api.h)

SET(SC3_PACKAGE_ROOT_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})

# Default directories that can be overridden in the
# subprojects
SET(SC3_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
SET(SC3_PACKAGE_BIN_DIR bin)
SET(SC3_PACKAGE_LIB_DIR lib)
SET(SC3_PACKAGE_INCLUDE_DIR include)
SET(SC3_PACKAGE_SHARE_DIR share)
SET(SC3_PACKAGE_CONFIG_DIR etc)
SET(SC3_PACKAGE_TEMPLATES_DIR templates)

# Platform check
#
IF (APPLE AND ${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
	SET (MACOSX 1)
	MESSAGE(STATUS "MACOSX detected")
ELSEIF (UNIX AND ${CMAKE_SYSTEM_NAME} MATCHES "Linux")
 	SET (LINUX 1)
ENDIF (APPLE AND ${CMAKE_SYSTEM_NAME} MATCHES "Darwin")

# If gcc is installed add -wall and -pedantic to the commandline
#
IF (CMAKE_COMPILER_IS_GNUCC)
	IF ( ${CMAKE_BUILD_TYPE} MATCHES "Debug" )
		ADD_DEFINITIONS(-Wall -pedantic -Wno-long-long -Wno-variadic-macros)
		#ADD_DEFINITIONS(-Wall -Wno-long-long -Wno-variadic-macros)
	ELSE ( ${CMAKE_BUILD_TYPE} MATCHES "Debug" )
		ADD_DEFINITIONS(-Wall)
	ENDIF ( ${CMAKE_BUILD_TYPE} MATCHES "Debug" )

	# Query gcc version. We can't use CMAKE_CXX_COMPILER_VERSION which is
	# only supported in cmake >= 2.8.10. SLES 11 still comes with cmake 2.6.
	EXECUTE_PROCESS(
		COMMAND ${CMAKE_C_COMPILER} -dumpversion
		OUTPUT_VARIABLE GCC_VERSION
	)

	STRING(REGEX MATCHALL "[0-9]+" GCC_VERSION_COMPONENTS ${GCC_VERSION})
	LIST(LENGTH GCC_VERSION_COMPONENTS GCC_VERSION_COMPONENTS_SIZE)
	LIST(GET GCC_VERSION_COMPONENTS 0 GCC_VERSION_MAJOR)
	# E.g. Fedora 26 does by default report only the major version number (7)
	# The new option "-dumpfullversion" is not available on older compilers
	IF(GCC_VERSION_COMPONENTS_SIZE GREATER 1)
		LIST(GET GCC_VERSION_COMPONENTS 1 GCC_VERSION_MINOR)
	ELSE(GCC_VERSION_COMPONENTS_SIZE GREATER 1)
		SET(GCC_VERSION_MINOR 0)
	ENDIF(GCC_VERSION_COMPONENTS_SIZE GREATER 1)

	MESSAGE(STATUS "Found GCC version ${GCC_VERSION_MAJOR}.${GCC_VERSION_MINOR}")

	IF(GCC_VERSION VERSION_LESS "5.0")
		MESSAGE(FATAL_ERROR "GCC version ${GCC_VERSION} found but at least 5.0 required as minimum. Version 9 or later is preferrable.")
	ENDIF()

	# Enable C++17 features
	SET(CMAKE_CXX_STANDARD 17)
	SET(CMAKE_CXX_STANDARD_REQUIRED ON)

	# Modern GCC (>= 5.1) on old systems with libraries compiled with ABI version 0.
	# see https://gcc.gnu.org/onlinedocs/libstdc++/manual/using_dual_abi.html
	IF ( FORCE_CXX11_ABI_0 )
		ADD_COMPILE_DEFINITIONS(_GLIBCXX_USE_CXX11_ABI=0)
	ENDIF ()
ENDIF (CMAKE_COMPILER_IS_GNUCC)

# Set the platform specific suffix for dynamic libraries
ADD_DEFINITIONS(
	-DSHARED_LIBRARY_SUFFIX="${CMAKE_SHARED_LIBRARY_SUFFIX}"
	-DSHARED_MODULE_SUFFIX="${CMAKE_SHARED_MODULE_SUFFIX}"
 )

# Helper for Eclipse CDT
#
IF (CMAKE_COMPILER_IS_GNUCC)
	SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fmessage-length=0")
ENDIF(CMAKE_COMPILER_IS_GNUCC)
IF (CMAKE_COMPILER_IS_GNUCXX)
	IF (CMAKE_CXX_COMPILER_VERSION VERSION_LESS "7.0.0")
		MESSAGE(FATAL_ERROR "Insufficient GCC version. At least version \
7.0.0 is required for C++17 language features.")
	ENDIF ()

	SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fmessage-length=0")
ENDIF(CMAKE_COMPILER_IS_GNUCXX)

ADD_DEFINITIONS(-D_REENTRANT)

IF(SC_GLOBAL_UNITTESTS)
	MESSAGE(STATUS "Enable unit tests")
	FIND_PACKAGE(Boost REQUIRED COMPONENTS unit_test_framework)
	ENABLE_TESTING()
ELSE(SC_GLOBAL_UNITTESTS)
	FIND_PACKAGE(Boost)
	MESSAGE(STATUS "Disable unit tests")
ENDIF(SC_GLOBAL_UNITTESTS)

SUBDIRS(src doc)
