# flex a .l file

IF(APPLE)
    IF (EXISTS "/Library/Developer/CommandLineTools/usr/include/FlexLexer.h" )
        SET(FLEX_INCLUDE_DIR "/Library/Developer/CommandLineTools/usr/include/")
        INCLUDE_DIRECTORIES(${FLEX_INCLUDE_DIR})
    ELSE()
        MESSAGE(STATUS,"macOS default /Library/Developer/CommandLineTools/usr/include/FlexLexer.h not found! Checking Homebrew version of flex.")
		EXECUTE_PROCESS(COMMAND brew --prefix flex
			RESULT_VARIABLE BREW_FLEX
			OUTPUT_VARIABLE BREW_FLEX_PREFIX
			OUTPUT_STRIP_TRAILING_WHITESPACE
		)
		IF(BREW_FLEX EQUAL 0 AND EXISTS "${BREW_FLEX_PREFIX}")
			MESSAGE(STATUS "Found flex installed by Homebrew at ${BREW_FLEX_PREFIX}")
			SET(FLEX_EXECUTABLE ${BREW_FLEX_PREFIX}/bin/flex)
			SET(FLEX_INCLUDE_DIR ${BREW_FLEX_PREFIX}/include/)
			INCLUDE_DIRECTORIES(${FLEX_INCLUDE_DIR})
		ELSE()
			MESSAGE(FATAL_ERROR "Homebrew version of flex not found! Install with: brew install flex")
		ENDIF()
	ENDIF()	
ENDIF(APPLE)

# search flex
MACRO(FIND_FLEX)
	IF(NOT FLEX_EXECUTABLE)
		FIND_PROGRAM(FLEX_EXECUTABLE flex)
		IF (NOT FLEX_EXECUTABLE)
			MESSAGE(FATAL_ERROR "flex not found - aborting")
		ENDIF (NOT FLEX_EXECUTABLE)
	ENDIF(NOT FLEX_EXECUTABLE)

	IF(NOT FLEX_INCLUDE_DIR)
		FIND_PATH(FLEX_INCLUDE_DIR FlexLexer.h)
		IF (NOT FLEX_INCLUDE_DIR)
			MESSAGE(FATAL_ERROR "FlexLexer.h not found - aborting")
		ENDIF (NOT FLEX_INCLUDE_DIR)
	ENDIF (NOT FLEX_INCLUDE_DIR)
ENDMACRO(FIND_FLEX)

MACRO(ADD_FLEX_FILES _sources)
	FIND_FLEX()
	FOREACH (_current_FILE ${ARGN})
		GET_FILENAME_COMPONENT(_in ${_current_FILE} ABSOLUTE)
		GET_FILENAME_COMPONENT(_basename ${_current_FILE} NAME_WE)
		SET(_out ${CMAKE_CURRENT_BINARY_DIR}/flex_${_basename}.cc)
		ADD_CUSTOM_COMMAND(
			OUTPUT ${_out}
			COMMAND ${FLEX_EXECUTABLE}
			ARGS -o${_out} ${_in}
			DEPENDS ${_in} ${FLEX_EXECUTABLE} ${FLEX_INCLUDE_DIR}/FlexLexer.h)
		SET(${_sources} ${${_sources}} ${_out})
	ENDFOREACH (_current_FILE)
ENDMACRO(ADD_FLEX_FILES)


