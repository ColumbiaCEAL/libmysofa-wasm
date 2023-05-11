# CMake generated Testfile for 
# Source directory: /Users/arcop/code/git/libmysofa-wasm/src
# Build directory: /Users/arcop/code/git/libmysofa-wasm/build-ninja/src
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(external "/Users/arcop/code/git/emsdk/node/15.14.0_64bit/bin/node" "--experimental-wasm-bulk-memory" "--experimental-wasm-threads" "/Users/arcop/code/git/libmysofa-wasm/build-ninja/src/external.js")
set_tests_properties(external PROPERTIES  WORKING_DIRECTORY "/Users/arcop/code/git/libmysofa-wasm" _BACKTRACE_TRIPLES "/Users/arcop/code/git/libmysofa-wasm/src/CMakeLists.txt;179;add_test;/Users/arcop/code/git/libmysofa-wasm/src/CMakeLists.txt;0;")
add_test(internal "/Users/arcop/code/git/emsdk/node/15.14.0_64bit/bin/node" "--experimental-wasm-bulk-memory" "--experimental-wasm-threads" "/Users/arcop/code/git/libmysofa-wasm/build-ninja/src/internal.js")
set_tests_properties(internal PROPERTIES  WORKING_DIRECTORY "/Users/arcop/code/git/libmysofa-wasm" _BACKTRACE_TRIPLES "/Users/arcop/code/git/libmysofa-wasm/src/CMakeLists.txt;186;add_test;/Users/arcop/code/git/libmysofa-wasm/src/CMakeLists.txt;0;")
add_test(multithread "/Users/arcop/code/git/emsdk/node/15.14.0_64bit/bin/node" "--experimental-wasm-bulk-memory" "--experimental-wasm-threads" "/Users/arcop/code/git/libmysofa-wasm/build-ninja/src/multithread.js")
set_tests_properties(multithread PROPERTIES  WORKING_DIRECTORY "/Users/arcop/code/git/libmysofa-wasm" _BACKTRACE_TRIPLES "/Users/arcop/code/git/libmysofa-wasm/src/CMakeLists.txt;197;add_test;/Users/arcop/code/git/libmysofa-wasm/src/CMakeLists.txt;0;")
