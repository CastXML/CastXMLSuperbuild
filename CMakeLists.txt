cmake_minimum_required(VERSION 2.8)

project(CastXMLSuperbuild)


# Set a default build type if none was specified
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to 'Release' as none was specified.")
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()


include(ExternalProject)


set(llvm_version 3.6.0)
ExternalProject_Add(llvm
  # This is the upstream source code repackages in a .tar.gz for
  # compatibility with older CMake. Also the tests/ and doc/ directories
  # are removed to remove symlink files and save space.
  URL http://midas3.kitware.com/midas/download/bitstream/454187/llvm-${llvm_version}.src.tar.gz
  URL_MD5 53dfa661317af324838b3c13c6e58770
  CMAKE_ARGS -Wno-dev
  CMAKE_GENERATOR "${CMAKE_GENERATOR}"
  CMAKE_CACHE_ARGS
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    "-DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS} -w"
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    "-DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS} -w"
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
  INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/llvm
  )


ExternalProject_Add(clang
  # This is the upstream source code repackages in a .tar.gz for
  # compatibility with older CMake. Also the tests/ and doc/ directories
  # are removed to remove symlink files and save space.
  URL http://midas3.kitware.com/midas/download/bitstream/454206/cfe-${llvm_version}.src.tar.gz
  URL_MD5 d6da7200e9ee9f956565a15242e5a5fe
  DEPENDS llvm
  SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/cfe-${llvm_version}
  CMAKE_ARGS -Wno-dev
  CMAKE_GENERATOR "${CMAKE_GENERATOR}"
  CMAKE_CACHE_ARGS
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    "-DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS} -w"
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    "-DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS} -w"
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DCLANG_INCLUDE_DOCS:BOOL=OFF
    -DCLANG_INCLUDE_TESTS:BOOL=OFF
    -DLLVM_CONFIG:PATH=${CMAKE_CURRENT_BINARY_DIR}/llvm/bin/llvm-config${exe}
  INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/llvm
  )


if(CMAKE_COMPILER_IS_GNUCXX AND CMAKE_SYSTEM_NAME MATCHES "Linux")
  set(extra_flags "-static-libstdc++")
endif()
set(CastXML_GIT_TAG master CACHE STRING "CastXML Git revision.")
ExternalProject_Add(castxml
  GIT_REPOSITORY https://github.com/CastXML/CastXML.git
  GIT_TAG ${CastXML_GIT_TAG}
  DEPENDS llvm clang
  CMAKE_ARGS -Wno-dev
  CMAKE_GENERATOR "${CMAKE_GENERATOR}"
  CMAKE_CACHE_ARGS
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    "-DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS} -w ${extra_flags}"
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    "-DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS} -w"
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DLLVM_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR}/llvm/share/llvm/cmake
  INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/llvm
  )
