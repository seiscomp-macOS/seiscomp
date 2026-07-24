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
    # Use cmake's FindSQLite3 module 
    FIND_PACKAGE(SQLite3 REQUIRED)
    
    # On macOS we use cmake's internal FindSQLite3 (since cmake v3.14)
	# Note cmake's results name are: SQLite3_INCLUDE_DIRS and SQLite3_LIBRARIES
	# but SeisComP uses uppercase: SQLITE3_INCLUDE_DIR & SQLITE3_LIBRARIES so we need to set this when found.
	IF(SQLite3_FOUND)
	    MESSAGE(STATUS "macOS SQLite3 found!")
	    MESSAGE(STATUS "macOS SQLite3_INCLUDE_DIRS: ${SQLite3_INCLUDE_DIRS} ")
	    MESSAGE(STATUS "macOS SQLite3_LIBRARIES: ${SQLite3_LIBRARIES} ")
	    SET(SQLITE3_INCLUDE_DIR ${SQLite3_INCLUDE_DIRS})
	    SET(SQLITE3_LIBRARIES ${SQLite3_LIBRARIES})
	ELSE()
	    MESSAGE(STATUS "macOS SQLite not found! macOS has its own SQLite3 version installed when Xcode or CommandLineTools are installed. Either install Xcode.app or CommandLineTools ")    
	    MESSAGE(FATAL_ERROR "or as analternative install sqlite3 with Homebrew: brew install sqlite")    
	ENDIF()
ENDIF(APPLE)

IF(NOT APPLE)
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
ENDIF(NOT APPLE)
