# - Find the native FFTW3 includes and library
#

# This module defines
#  FFTW3_INCLUDE_DIR, where to find fftw3.h, etc.
#  FFTW3_LIBRARIES, the libraries to link against to use fftw3.
#  FFTW3_DEFINITIONS - You should ADD_DEFINITONS(${FFTW3_DEFINITIONS}) before compiling code that includes fftw3 library files.
#  FFTW3_FOUND, If false, do not try to use fftw3.

SET(FFTW3_FOUND "NO")

IF(NOT APPLE)
    FIND_PATH(FFTW3_INCLUDE_DIR fftw3.h
    /usr/include/fftw3
    /usr/local/include/fftw3
    )
ENDIF(NOT APPLE)

IF(APPLE)
    # On macOS Homebrew fftw3 version is called "fftw"
    EXECUTE_PROCESS(COMMAND brew --prefix fftw
        RESULT_VARIABLE BREW_FFTW3
        OUTPUT_VARIABLE BREW_FFTW3_PREFIX
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )    
    IF(BREW_FFTW3 EQUAL 0 AND EXISTS "${BREW_FFTW3_PREFIX}")
        MESSAGE(STATUS "Found FFTW3 installed by Homebrew at ${BREW_FFTW3_PREFIX}")
        SET(FFTW3_INCLUDE_DIR "${BREW_FFTW3_PREFIX}"/include/)
        SET(FFTW3_LIBRARY "${BREW_FFTW3_PREFIX}/lib/")
    ELSE()
         MESSAGE(FATAL_ERROR "Homebrew version of fftw not found. Install with: brew install fftw")
    ENDIF()
ENDIF(APPLE)
    
SET(FFTW3_NAMES ${FFTW3_NAMES} fftw3)
FIND_LIBRARY(FFTW3_LIBRARY
    NAMES ${FFTW3_NAMES}
)

IF (FFTW3_LIBRARY AND FFTW3_INCLUDE_DIR)
    SET(FFTW3_LIBRARIES ${FFTW3_LIBRARY})
    SET(FFTW3_FOUND "YES")
ENDIF (FFTW3_LIBRARY AND FFTW3_INCLUDE_DIR)

IF (FFTW3_FOUND)
    IF (NOT FFTW3_FIND_QUIETLY)
	MESSAGE(STATUS "Found fftw3: ${FFTW3_LIBRARY}")
    ENDIF (NOT FFTW3_FIND_QUIETLY)
    MARK_AS_ADVANCED(FFTW3_INCLUDE_DIR FFTW3_LIBRARIES FFTW3_LIBRARY)
ELSE (FFTW3_FOUND)
    IF (FFTW3_FIND_REQUIRED)
	MESSAGE(FATAL_ERROR "Could not find fftw3 library")
    ENDIF (FFTW3_FIND_REQUIRED)
ENDIF (FFTW3_FOUND)
