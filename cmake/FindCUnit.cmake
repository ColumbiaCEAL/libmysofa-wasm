# - Try to find cunit
# Once done this will define
#  CUNIT_FOUND        - System has cunit
#  CUNIT_INCLUDE_DIRS - The cunit include directories
#  CUNIT_LIBRARIES    - The libraries needed to use cunit

find_package(PkgConfig)
#pkg_check_modules(PC_CUNIT cunit)

find_path(CUNIT_INCLUDE_DIR
  NAMES CUnit/CUnit.h CUnit/Basic.h
  HINTS ${PC_CUNIT_INCLUDE_DIRS} C:/projects/cunit/include
)
# find_library(CUNIT_LIBRARY
#   NAMES libcunit
#   HINTS /Users/arcop/code/git/cunit/local-build/CUnit/
#   # HINTS ${PC_CUNIT_LIBRARY_DIRS} /Users/arcop/code/git/cunit/local-build/CUnit/libcunit.a # C:/projects/cunit/lib/Release-x64
# )

set(CUNIT_LIBRARY "/Users/arcop/code/git/cunit/local-build/CUnit/libcunit.a")
set(CUNIT_INCLUDE_DIR "/Users/arcop/code/git/cunit/CUnit/")

message("CUNIT lib path:")
message(${CUNIT_LIBRARY})



if(CUNIT_INCLUDE_DIR)
  set(_version_regex "^#define[ \t]+CU_VERSION[ \t]+\"([^\"]+)\".*")
  file(STRINGS "${CUNIT_INCLUDE_DIR}/CUnit/CUnit.h"
    CUNIT_VERSION REGEX "${_version_regex}")
  string(REGEX REPLACE "${_version_regex}" "\\1"
    CUNIT_VERSION "${CUNIT_VERSION}")
  unset(_version_regex)
endif()

message("CUNIT include dir:")
message(${CUNIT_INCLUDE_DIR})

include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set CUNIT_FOUND to TRUE
# if all listed variables are TRUE and the requested version matches.
find_package_handle_standard_args(CUnit REQUIRED_VARS
                                  CUNIT_LIBRARY CUNIT_INCLUDE_DIR
                                  VERSION_VAR CUNIT_VERSION)

if(CUNIT_FOUND)
  set(CUNIT_LIBRARIES     ${CUNIT_LIBRARY})
  set(CUNIT_INCLUDE_DIRS  ${CUNIT_INCLUDE_DIR})
  message("found library and include dir")
endif()

mark_as_advanced(CUNIT_INCLUDE_DIR CUNIT_LIBRARY)
