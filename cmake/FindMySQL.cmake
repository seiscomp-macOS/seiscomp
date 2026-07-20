# - Find MySQL
# Find the MySQL includes and client library
# This module defines
#  MYSQL_INCLUDE_DIR, where to find mysql.h
#  MYSQL_LIBRARIES, the libraries needed to use MySQL.
#  MYSQL_FOUND, If false, do not try to use MySQL.
#
# Copyright (c) 2006, Jaroslaw Staniek, <js@iidea.pl>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.
#
# Modified by Jan Becker, <jabe@gfz-potsdam.de>
#  * added REQUIRED and QUIETLY check
#  * search for mysql/mysql.h instead of just mysql.h 

IF(APPLE)
     # Find Homebrew version of MariaDB (an open-source drop-in replacement of MySQL)
	EXECUTE_PROCESS(COMMAND brew --prefix mariadb
	    RESULT_VARIABLE BREW_MARIADB_RESULT
	    OUTPUT_VARIABLE BREW_MARIADB_PREFIX
	    OUTPUT_STRIP_TRAILING_WHITESPACE
	)

	IF(BREW_MARIADB_RESULT EQUAL 0 AND EXISTS "${BREW_MARIADB_PREFIX}")
        MESSAGE(STATUS "Found MariaDB/MySQL installed by Homebrew at ${BREW_MYSQL_PREFIX}")
	    
        FIND_PATH(MYSQL_INCLUDE_DIR 
            NAMES mysql.h mariadb_version.h
            PATHS "${BREW_MARIADB_PREFIX}/include/mysql" "${BREW_MARIADB_PREFIX}/include/mariadb"
            NO_DEFAULT_PATH
        )

        FIND_LIBRARY(MYSQL_LIBRARY 
            NAMES mariadb mariadbclient mysqlclient
            PATHS "${BREW_MARIADB_PREFIX}/lib"
            NO_DEFAULT_PATH
        )
        
        IF(MYSQL_INCLUDE_DIR AND MYSQL_LIBRARY)
            SET(MYSQL_LIBRARIES ${MYSQL_LIBRARY})
            SET(MYSQL_FOUND TRUE)
            MESSAGE(STATUS "Homebrew MariaDB Headers: ${MYSQL_INCLUDE_DIR}")
            MESSAGE(STATUS "Homebrew MariaDB Library: ${MYSQL_LIBRARIES}")
        ELSE()
            MESSAGE(WARNING "MariaDB found by brew, but headers or libraries are missing inside the prefix.")
        ENDIF()
    ELSE()
        MESSAGE(FATAL_ERROR "Homebrew version of Mariadb not found. Install with: brew install mariadb")
    ENDIF()
        
ENDIF()

IF(NOT APPLE)			
    if(MYSQL_INCLUDE_DIR AND MYSQL_LIBRARIES)
        set(MYSQL_FOUND TRUE)

    else(MYSQL_INCLUDE_DIR AND MYSQL_LIBRARIES)

    find_path(MYSQL_INCLUDE_DIR mysql/mysql.h
      $ENV{ProgramFiles}/MySQL/*/include
      $ENV{SystemDrive}/MySQL/*/include
      )

    find_library(MYSQL_LIBRARIES NAMES mysqlclient
      PATHS
      /usr/lib/mysql
      /usr/local/lib/mysql
      $ENV{ProgramFiles}/MySQL/*/lib/opt
      $ENV{SystemDrive}/MySQL/*/include
      )

    if(MYSQL_INCLUDE_DIR AND MYSQL_LIBRARIES)
        set(MYSQL_FOUND TRUE)
        if(NOT MySQL_FIND_QUIETLY)
	        message(STATUS "Found MySQL: ${MYSQL_INCLUDE_DIR}, ${MYSQL_LIBRARIES}")
        endif(NOT MySQL_FIND_QUIETLY)
    else(MYSQL_INCLUDE_DIR AND MYSQL_LIBRARIES)
        set(MYSQL_FOUND FALSE)
        if(MySQL_FIND_REQUIRED)
	    message(FATAL_ERROR "MySQL not found.")
        else(MySQL_FIND_REQUIRED)
	if(NOT MySQL_FIND_QUIETLY)
	    message(STATUS "MySQL not found.")
	endif(NOT MySQL_FIND_QUIETLY)
    endif(MySQL_FIND_REQUIRED)
    endif(MYSQL_INCLUDE_DIR AND MYSQL_LIBRARIES)

    mark_as_advanced(MYSQL_INCLUDE_DIR MYSQL_LIBRARIES)

endif(MYSQL_INCLUDE_DIR AND MYSQL_LIBRARIES)
ENDIF()
