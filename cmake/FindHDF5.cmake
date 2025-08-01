# - Find the native HDF5 includes and library
#

# This module defines
#  HDF5_INCLUDE_DIR, where to find fftw3.h, etc.
#  HDF5_LIBRARIES, the libraries to link against to use fftw3.
#  HDF5_DEFINITIONS - You should ADD_DEFINITONS(${HDF5_DEFINITIONS}) before compiling code that includes hdf5 library files.
#  HDF5_FOUND, If false, do not try to use hdf5.

SET(HDF5_FOUND "NO")

IF(NOT APPLE)
    FIND_PATH(HDF5_INCLUDE_DIR hdf5.h
        /usr/include/
        /usr/local/include/
    )
ENDIF(NOT APPLE)

IF(APPLE)
    EXECUTE_PROCESS(COMMAND brew --prefix hdf5
        RESULT_VARIABLE BREW_HDF5
        OUTPUT_VARIABLE BREW_HDF5_PREFIX
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    IF(BREW_HDF5 EQUAL 0 AND EXISTS "${BREW_HDF5_PREFIX}")
        MESSAGE(STATUS "Found HDF5 installed by Homebrew at ${BREW_HDF5_PREFIX}")
        SET(HDF5_INCLUDE_DIR "${BREW_HDF5_PREFIX}"/include/)
        SET(HDF5_LIBRARY "${BREW_HDF5_PREFIX}/lib/")
    ELSE()
         MESSAGE(FATAL_ERROR "Homebrew version of HDF5 not found. Install with: brew install hdf5")
    ENDIF()
ENDIF(APPLE)

SET(HDF5_NAMES ${HDF5_NAMES} hdf5)
FIND_LIBRARY(HDF5_LIBRARY
    NAMES ${HDF5_NAMES}
)

IF (HDF5_LIBRARY AND HDF5_INCLUDE_DIR)
    SET(HDF5_LIBRARIES ${HDF5_LIBRARY})
    SET(HDF5_FOUND "YES")
ENDIF (HDF5_LIBRARY AND HDF5_INCLUDE_DIR)

IF (HDF5_FOUND)
    IF (NOT HDF5_FIND_QUIETLY)
	MESSAGE(STATUS "Found hdf5: ${HDF5_LIBRARY}")
    ENDIF (NOT HDF5_FIND_QUIETLY)
    MARK_AS_ADVANCED(HDF5_INCLUDE_DIR HDF5_LIBRARIES HDF5_LIBRARY)
ELSE (HDF5_FOUND)
    IF (HDF5_FIND_REQUIRED)
	MESSAGE(FATAL_ERROR "Could not find hdf5 library")
    ENDIF (HDF5_FIND_REQUIRED)
ENDIF (HDF5_FOUND)
