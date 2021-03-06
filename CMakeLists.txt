 #  Copyright 2019 Christopher Edwards
 # 
 # Licensed under the Apache License, Version 2.0 (the "License");
 # you may not use this file except in compliance with the License.
 # You may obtain a copy of the License at
 # 
 #     http://www.apache.org/licenses/LICENSE-2.0
 # 
 # Unless required by applicable law or agreed to in writing, software
 # distributed under the License is distributed on an "AS IS" BASIS,
 # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 # See the License for the specific language governing permissions and
 # limitations under the License.

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/ydbcmake/")
set(M_EMBED_SOURCE TRUE)
set(M_DYNAMIC_LITERALS TRUE)

project(YDBGUI C M)
cmake_minimum_required(VERSION 2.8)

# Find YottaDB
find_package(YOTTADB REQUIRED)
include_directories("${YOTTADB_INCLUDE_DIRS}")

set(ydb_install_dir ${YOTTADB_INCLUDE_DIRS}/plugin)

# Make sure npm & node are installed
find_program(NPM NAMES npm)
find_program(NODE NAMES node)

if(NOT NPM)
  message(FATAL_ERROR "Unable to find 'npm'.  Please install npm and make sure it is available in your path.")
endif()

if(NOT NODE)
  message(FATAL_ERROR "Unable to find 'node'.  Please install node.js and make sure it is available in your path.")
endif()

# Make sure the m web server is installed
set(CMAKE_FIND_LIBRARY_PREFIXES "")
find_library(MWEBSERVER NAMES ydbmwebserver HINTS ${ydb_install_dir}/o)

if(NOT MWEBSERVER)
  message(FATAL_ERROR "Unable to find 'M-Web-Server'.  Please install the M-Web-Server YottaDB plugin.")
endif()

set(source_files
  r/GDEWEB.m
  r/_weburl.m
)

# Add commands to compile .m files
add_library(ydbgui SHARED ${source_files})

SET_TARGET_PROPERTIES(ydbgui PROPERTIES PREFIX "")

install(FILES ${source_files} DESTINATION ${ydb_install_dir}/r/)

if(M_UTF8_MODE)
  install(TARGETS ydbgui DESTINATION ${ydb_install_dir}/o/utf8)
else()
  install(TARGETS ydbgui DESTINATION ${ydb_install_dir}/o/)
endif()

# Run the NPM build setps
execute_process(COMMAND npm install)
add_custom_target(npmbuild ALL COMMAND npm run build)

# HTML files
install(DIRECTORY dist/ DESTINATION ${ydb_install_dir}/etc/ydbgui)
