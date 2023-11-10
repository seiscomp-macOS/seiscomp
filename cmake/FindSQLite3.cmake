# - Find SQLite3
# Find the SQLite includes and library
# This module defines
#  SQLITE3_INCLUDE_DIR, where to find mysql.h
#  SQLITE3_LIBRARIES, the libraries needed to use MySQL.
#  SQLITE3_FOUND, If false, do not try to use MySQL.
#
# Copyright (c) 2006, Jaroslaw Staniek, <js@iidea.pl>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.
#
# Modified by Jan Becker, <jabe@gfz-potsdam.de>
#  * added REQUIRED and QUIETLY check

IF(APPLE)
		EXECUTE_PROCESS(COMMAND brew --prefix sqlite
			RESULT_VARIABLE BREW_SQLITE3
			OUTPUT_VARIABLE BREW_SQLITE3_PREFIX
			OUTPUT_STRIP_TRAILING_WHITESPACE
		)
		IF(BREW_SQLITE3 EQUAL 0 AND EXISTS "${BREW_SQLITE3_PREFIX}")
			MESSAGE(STATUS "Found SQLITE3 installed by Homebrew at ${BREW_SQLITE3_PREFIX}")
			SET(SQLITE3_EXECUTABLE ${BREW_SQLITE3_PREFIX}/bin/SQLITE3)
			SET(SQLITE3_INCLUDE_DIR ${BREW_SQLITE3_PREFIX}/include/)
			INCLUDE_DIRECTORIES(${SQLITE3_INCLUDE_DIR})
		ELSE()
			MESSAGE(FATAL_ERROR "Homebrew version of SQLite3 not found! Install with: brew install sqlite")
		ENDIF()
ENDIF(APPLE)

if(SQLITE3_INCLUDE_DIR AND SQLITE3_LIBRARIES)
   set(SQLITE3_FOUND TRUE)

else(SQLITE3_INCLUDE_DIR AND SQLITE3_LIBRARIES)

  find_path(SQLITE3_INCLUDE_DIR sqlite3.h)

  find_library(SQLITE3_LIBRARIES NAMES sqlite3)

  if(SQLITE3_INCLUDE_DIR AND SQLITE3_LIBRARIES)
    set(SQLITE3_FOUND TRUE)
    if(NOT SQLite3_FIND_QUIETLY)
	message(STATUS "Found SQLite3: ${SQLITE3_INCLUDE_DIR}, ${SQLITE3_LIBRARIES}")
    endif(NOT SQLite3_FIND_QUIETLY)
  else(SQLITE3_INCLUDE_DIR AND SQLITE3_LIBRARIES)
    set(SQLITE3_FOUND FALSE)
    if(SQLite3_FIND_REQUIRED)
	message(FATAL_ERROR "SQLite3 not found.")
    else(SQLite3_FIND_REQUIRED)
	if(NOT SQLite3_FIND_QUIETLY)
	    message(STATUS "SQLite3 not found.")
	endif(NOT SQLite3_FIND_QUIETLY)
    endif(SQLite3_FIND_REQUIRED)
  endif(SQLITE3_INCLUDE_DIR AND SQLITE3_LIBRARIES)

  mark_as_advanced(SQLITE3_INCLUDE_DIR SQLITE3_LIBRARIES)

endif(SQLITE3_INCLUDE_DIR AND SQLITE3_LIBRARIES)
