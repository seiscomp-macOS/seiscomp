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
    EXECUTE_PROCESS(COMMAND brew --prefix mysql
	  RESULT_VARIABLE BREW_MYSQL
	  OUTPUT_VARIABLE BREW_MYSQL_PREFIX
	  OUTPUT_STRIP_TRAILING_WHITESPACE
	)
    
    IF(BREW_MYSQL EQUAL 0 AND EXISTS "${BREW_MYSQL_PREFIX}")
	    MESSAGE(STATUS "Found MySQL installed by Homebrew at ${BREW_MYSQL_PREFIX}")
	    SET(MySQL_DIR ${BREW_MYSQL_PREFIX})
	    SET(MYSQL_INCLUDE_DIR ${BREW_MYSQL_PREFIX}/include)
	    SET(MYSQL_LIBRARIES ${BREW_MYSQL_PREFIX}/lib/libmysqlclient.dylib)
	ELSE()
    	# macOS: Some user(s) prefer MariaDB over MySQL
        # find Homebrew version of MariaDB (an open-source drop-in replacement of MySQL)
	    EXECUTE_PROCESS(COMMAND brew --prefix mariadb
	        RESULT_VARIABLE BREW_MARIADB
	        OUTPUT_VARIABLE BREW_MARIADB_PREFIX
	        OUTPUT_STRIP_TRAILING_WHITESPACE
	    )

	    IF(BREW_MARIADB EQUAL 0 AND EXISTS "${BREW_MARIADB_PREFIX}")
            MESSAGE(STATUS "Found MariaDB/MySQL installed by Homebrew at ${BREW_MYSQL_PREFIX}")
	        SET(MySQL_DIR ${BREW_MARIADB_PREFIX})
	        SET(MYSQL_INCLUDE_DIR ${BREW_MARIADB_PREFIX}/include)
	        SET(MYSQL_LIBRARIES ${BREW_MARIADB_PREFIX}/lib/libmysqlclient.dylib)    
        ELSE()
            MESSAGE(FATAL_ERROR "Homebrew MySQL/MariaDB not found! Either install MariaDB OR MySQL, but NOT both together with command: brew install mysql OR brew install mariadb")
        ENDIF()
    ENDIF()
ENDIF(APPLE)
				
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
