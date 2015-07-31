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


set(llvm_version 3.7.0rc1)
ExternalProject_Add(llvm
  # This is the upstream source code repackaged in a .tar.gz for
  # compatibility with older CMake. Also the tests/ directory
  # removed to save space.
  URL http://midas3.kitware.com/midas/download/bitstream/456383/llvm-${llvm_version}.src.tar.gz
  URL_MD5 e0c06777f07b85db4ffce4c4e8b2939d
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
  # This is the upstream source code repackaged in a .tar.gz for
  # compatibility with older CMake. Also the tests/ directory
  # removed to save space.
  URL http://midas3.kitware.com/midas/download/bitstream/456384/cfe-${llvm_version}.src.tar.gz
  URL_MD5 73afc5b99b24f6d1451765dbdc7f44d5
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
    -DLLVM_CONFIG:PATH=${CMAKE_CURRENT_BINARY_DIR}/llvm/bin/llvm-config
  INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/llvm
  )


set(CastXML_GIT_TAG master CACHE STRING "CastXML Git revision.")
ExternalProject_Add(castxml
  GIT_REPOSITORY https://github.com/CastXML/CastXML.git
  GIT_TAG ${CastXML_GIT_TAG}
  DEPENDS llvm clang
  CMAKE_ARGS -Wno-dev
  CMAKE_GENERATOR "${CMAKE_GENERATOR}"
  CMAKE_CACHE_ARGS
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    "-DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS} -w"
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    "-DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS} -w"
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DLLVM_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR}/llvm/share/llvm/cmake
  INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/llvm
  )
