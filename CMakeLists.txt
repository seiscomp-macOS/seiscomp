CMAKE_MINIMUM_REQUIRED(VERSION 3.10.0 FATAL_ERROR)
CMAKE_POLICY(SET CMP0003 NEW)
CMAKE_POLICY(SET CMP0005 NEW)

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
FIND_PACKAGE(LibXml2 REQUIRED)

OPTION(SC_GLOBAL_UNITTESTS "Enable unit tests" ON)
OPTION(SC_GLOBAL_PYTHON_WRAPPER "Create Python 3 wrapper" ON)
OPTION(SC_GLOBAL_PYTHON_WRAPPER_NUMPY "Add Numpy support for Python 3 wrapper" ON)
OPTION(SC_ENABLE_CONTRIB "Enables descending into the contrib directory" ON)

# Modern GCC (>= 5.1) on old systems with libraries compiled with ABI version 0.
# see https://gcc.gnu.org/onlinedocs/libstdc++/manual/using_dual_abi.html
OPTION(FORCE_CXX11_ABI_0 "Option description" OFF)

SET(PythonInterp_FIND_VERSION 3)
SET(PythonInterp_FIND_VERSION_MAJOR 3)
SET(PythonInterp_FIND_VERSION_EXACT 0)
    IF(APPLE)

		MESSAGE(STATUS "PYTHON_EXECUTABLE used: 	${PYTHON_EXECUTABLE}")
		MESSAGE(STATUS "PYTHON_LIBRARIES used: 	${PYTHON_LIBRARIES}")
		MESSAGE(STATUS "PYTHON_INCLUDE_PATH used:${PYTHON_INCLUDE_PATH}")
		MESSAGE(STATUS "PYTHON_INCLUDE_DIR used:	${PYTHON_INCLUDE_DIR}")

	ENDIF(APPLE)
ENDIF(SC_GLOBAL_PYTHON_WRAPPER)


IF(NOT APPLE)
	SET(PythonInterp_FIND_VERSION 3)
	SET(PythonInterp_FIND_VERSION_MAJOR 3)
	SET(PythonInterp_FIND_VERSION_EXACT 0)
	FIND_PACKAGE(PythonInterp)
ENDIF(NOT APPLE)  

EXEC_PROGRAM(
	${PYTHON_EXECUTABLE}
	ARGS "-c \"import sys;print(sys.version[:3])\""
	OUTPUT_VARIABLE PYTHON_VERSION
)

IF(SC_GLOBAL_PYTHON_WRAPPER_NUMPY)
	IF(APPLE)
	    # macOS: find Homebrew version of NumPy
        EXECUTE_PROCESS(COMMAND brew --prefix numpy
	        RESULT_VARIABLE BREW_NUMPY
	        OUTPUT_VARIABLE BREW_NUMPY_PREFIX
	        OUTPUT_STRIP_TRAILING_WHITESPACE
	    )
		
	IF(BREW_NUMPY EQUAL 0 AND EXISTS "${BREW_NUMPY_PREFIX}")
	    MESSAGE(STATUS "Found NumPy installed by Homebrew at ${BREW_NUMPY_PREFIX}")
	    # Since cmake v3.14 can find component NumPy from Python3, which will not use cmake/FindNumpy.cmake but rather CMake's internal module FindPython3)
		# Note that you need to manually install NumPy site-package with command: "pip3 install numpy"
		FIND_PACKAGE(Python3 COMPONENTS NumPy)
		SET(PYTHON_NUMPY_INCLUDE_DIR ${Python3_NumPy_INCLUDE_DIRS})
		MESSAGE(STATUS "NumPy version found: ${Python3_NumPy_VERSION}")
	ELSE()
	    MESSAGE(STATUS"Homebrew version of NumPy not found!")
        MESSAGE(FATAL_ERROR "Install with: brew install numpy; pip3 install numpy")
    ENDIF()		

	ELSE()
		FIND_PACKAGE(Numpy)	
	ENDIF(APPLE)
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

IF(APPLE)
	# Check Mac architecture: arm64 (Apple Silicon) or x86_64 Mac INTEL
	EXECUTE_PROCESS(COMMAND uname -m 
	    OUTPUT_VARIABLE CMAKE_OSX_ARCHITECTURES
	    OUTPUT_STRIP_TRAILING_WHITESPACE
	)
	IF(${CMAKE_OSX_ARCHITECTURES} MATCHES "arm64" )
		  MESSAGE(STATUS "Detected Apple Silicon arm64 architecture")
		  SET(CMAKE_OSX_ARCHITECTURES "arm64" CACHE STRING "Apple Silicon Architectures")
		  SET(MACOS_HOMEBREW_PATH "/opt/homebrew/")
  		  SET(CMAKE_OSX_DEPLOYMENT_TARGET "11.0" CACHE STRING "")
          # For Clang's C-compiler add "-Wno-implicit-function-declaration" to avoid compile error (seedlink plugin locsat)
		  SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c11 -arch arm64 -Wno-implicit-function-declaration")
		  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -arch arm64")
	ELSEIF(${CMAKE_OSX_ARCHITECTURES} MATCHES "x86_64")
		  MESSAGE(STATUS "Detected Apple INTEL x86_64 architecture")
		  SET(CMAKE_OSX_ARCHITECTURES "x86_64" CACHE STRING "Apple INTEL Architectures")
		  SET(MACOS_HOMEBREW_PATH "/usr/local/")
	  	  SET(CMAKE_OSX_DEPLOYMENT_TARGET "10.14" CACHE STRING "")
	  	  # For Clang's C-compiler add "-Wno-implicit-function-declaration" to avoid compile error (seedlink plugin locsat)
		  SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c11 -arch x86_64 -Wno-implicit-function-declaration")
		  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -arch x86_64")
	ELSE()
		 MESSAGE(FATAL_ERROR "Unknown macOS architecture found!")
	ENDIF()
    
	IF(EXISTS "${MACOS_HOMEBREW_PATH}/bin/brew")
		MESSAGE(STATUS "Homebrew for macOS installed, continuing...")
	ELSE()
		MESSAGE(FATAL_ERROR "Homebrew for macOS not found. For installation instructions visit https://brew.sh/")
	ENDIF()
		
	# On macOS try to find (Homebrew) frameworks after system's standard libraries or headers. Default is FIRST.
    SET(CMAKE_FIND_FRAMEWORK LAST)
    	
    # Set RPATH for macOS - adds run-time search path for dynamic linking to libraries when building the applications
    # Avoids error "dyld: Library not loaded" when launching a compiled program
    SET(CMAKE_MACOSX_RPATH ON)
     
    # When compiling don't use the install RPATH already, but later on when installing
    SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
	
    # Add the automatically determined parts of the RPATH
    # which point to directories outside the build tree to the install RPATH
    SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
    
	SET(CMAKE_INSTALL_NAME_DIR "${CMAKE_INSTALL_PREFIX}/lib")
	
ENDIF(APPLE)

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
	MESSAGE(STATUS "Disable unit tests")
ENDIF(SC_GLOBAL_UNITTESTS)

SUBDIRS(src doc)
