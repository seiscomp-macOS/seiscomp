# Find the ncurses includes and library
#
# NCURSES_INCLUDE_DIR - Where to find ncurses.h
# NCURSES_LIBRARY    - Library to link against.
# NCURSES_FOUND      - Do not attempt to use if "no" or undefined.


IF(APPLE)
   # macOS: find Homebrew version of ncurses
   EXECUTE_PROCESS(
      COMMAND brew --prefix ncurses
	   RESULT_VARIABLE BREW_NCURSES
	   OUTPUT_VARIABLE BREW_NCURSES_PREFIX
	   OUTPUT_STRIP_TRAILING_WHITESPACE
   )
   IF(BREW_NCURSES EQUAL 0 AND EXISTS "${BREW_NCURSES_PREFIX}")
	    MESSAGE(STATUS "Found ncurses installed by Homebrew at ${BREW_NCURSES_PREFIX}")
	    SET(NCURSES_INCLUDE_DIR ${BREW_NCURSES_PREFIX}/include)
	    SET(NCURSES_LIBRARY_DIR ${BREW_NCURSES_PREFIX}/lib)
	    SET(NCURSES_LIBRARY ${BREW_NCURSES_PREFIX}/lib/libncurses.dylib)
	ENDIF()				
ENDIF(APPLE)

IF(NOT APPLE)
    FIND_PATH(NCURSES_INCLUDE_DIR ncurses.h
	    /usr/include 
	    /usr/local/include
	    /sw/include
    )

    FIND_LIBRARY(NCURSES_LIBRARY ncurses
	    /usr/lib 
	    /usr/local/lib
	    /sw/lib
    )
ENDIF(NOT APPLE)


IF (NCURSES_INCLUDE_DIR AND NCURSES_LIBRARY)
   SET(NCURSES_FOUND TRUE)
ENDIF (NCURSES_INCLUDE_DIR AND NCURSES_LIBRARY)


IF (NCURSES_FOUND)
   IF (NOT Ncurses_FIND_QUIETLY)
      MESSAGE(STATUS "Found ncurses: ${NCURSES_INCLUDE_DIR} ${NCURSES_LIBRARY}")
   ENDIF (NOT Ncurses_FIND_QUIETLY)
ELSE (NCURSES_FOUND)
   IF (Ncurses_FIND_REQUIRED)
      MESSAGE(FATAL_ERROR "Could not find ncurses")
   ENDIF (Ncurses_FIND_REQUIRED)
ENDIF (NCURSES_FOUND)
