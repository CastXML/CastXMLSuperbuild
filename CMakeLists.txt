cmake_minimum_required(VERSION 3.20)

project(CastXMLSuperbuild NONE)
# Set a default build type if none was specified
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to 'Release' as none was specified.")
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()
enable_language(C)
enable_language(CXX)


set(CMAKE_CXX_STANDARD "17")


if(APPLE)
  set(osx_args
    -DCMAKE_OSX_DEPLOYMENT_TARGET:STRING=10.11
    )
endif()


include(ExternalProject)

if(${CMAKE_VERSION} VERSION_LESS 3.24)
  set(download_extract_timestamp_flag)
else()
  set(download_extract_timestamp_flag DOWNLOAD_EXTRACT_TIMESTAMP TRUE)
endif()

find_program(NINJA_EXECUTABLE ninja)
if(NINJA_EXECUTABLE)
  set(CMAKE_GENERATOR "Ninja")
  # Make Ninja verbose so CircleCI does not think the build has halted.
  set(verbose_command BUILD_COMMAND ${NINJA_EXECUTABLE} ${BUILD_FLAGS} -v)
endif()

option(USE_SYSTEM_LLVM "Use the system LLVM instead of building it." OFF)
if(USE_SYSTEM_LLVM)
  find_package(LLVM REQUIRED NO_MODULE)
  set(castxml_deps)
else()

  set(llvm_version 19.1.7)
  set(llvm_folder 19.1.7)
  set(LLVM_DIR ${CMAKE_CURRENT_BINARY_DIR}/llvm/lib/cmake/llvm/)

  set(llvm_cmake_sha256 11c5a28f90053b0c43d0dec3d0ad579347fc277199c005206b963c19aae514e3)
  ExternalProject_Add(llvm-cmake
    URL "https://github.com/llvm/llvm-project/releases/download/llvmorg-${llvm_folder}/cmake-${llvm_version}.src.tar.xz"
    URL_HASH SHA256=${llvm_cmake_sha256}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    ${download_extract_timestamp_flag}
    LOG_BUILD 0
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/llvm-prefix/src/cmake
    )

  set(llvm_sha256 96f833c6ad99a3e8e1d9aca5f439b8fd2c7efdcf83b664e0af1c0712c5315910)
  ExternalProject_Add(llvm
    URL "https://github.com/llvm/llvm-project/releases/download/llvmorg-${llvm_folder}/llvm-${llvm_version}.src.tar.xz"
    URL_HASH SHA256=${llvm_sha256}
    DEPENDS llvm-cmake
    CMAKE_ARGS -Wno-dev
    CMAKE_GENERATOR "${CMAKE_GENERATOR}"
    CMAKE_CACHE_ARGS
      -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
      -DCMAKE_CXX_STANDARD:STRING=${CMAKE_CXX_STANDARD}
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
      -DLLVM_STATIC_LINK_CXX_STDLIB:BOOL=ON
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
      -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
      -DLLVM_INSTALL_PREFIX:PATH=<INSTALL_DIR>
      -DLLVM_ENABLE_TERMINFO:BOOL=OFF
      -DLLVM_INCLUDE_TESTS:BOOL=OFF
      -DLLVM_INCLUDE_BENCHMARKS:BOOL=OFF
      -DLLVM_INCLUDE_DOCS:BOOL=OFF
      -DLLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN:BOOL=ON
      ${osx_args}
    ${verbose_command}
    ${download_extract_timestamp_flag}
    LOG_BUILD 0
    INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/llvm
    )


  set(clang_sha256 11e5e4ecab5338b9914de3b83a4622cb200de466b7c56ba675afb72fa7d64675)
  ExternalProject_Add(clang
    URL "https://github.com/llvm/llvm-project/releases/download/llvmorg-${llvm_folder}/clang-${llvm_version}.src.tar.xz"
    URL_HASH SHA256=${clang_sha256}
    DEPENDS llvm
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/llvm-prefix/src/cfe-${llvm_version}
    CMAKE_ARGS -Wno-dev
    CMAKE_GENERATOR "${CMAKE_GENERATOR}"
    CMAKE_CACHE_ARGS
      -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
      -DCMAKE_CXX_STANDARD:STRING=${CMAKE_CXX_STANDARD}
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
      -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
      -DCLANG_INCLUDE_DOCS:BOOL=OFF
      -DCLANG_INCLUDE_TESTS:BOOL=OFF
      -DLLVM_INCLUDE_TESTS:BOOL=OFF
      -DLLVM_CONFIG:PATH=${CMAKE_CURRENT_BINARY_DIR}/llvm/bin/llvm-config
      -DLLVM_DIR:PATH=${LLVM_DIR}
      -DLLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN:BOOL=ON
      ${osx_args}
    ${verbose_command}
    ${download_extract_timestamp_flag}
    LOG_BUILD 0
    INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/llvm
    )

  set(castxml_deps llvm clang)
endif()


# Use a static C++ library on GCC/Linux
if(CMAKE_COMPILER_IS_GNUCXX AND CMAKE_SYSTEM_NAME MATCHES "Linux")
  set(linux_args "-DCMAKE_CXX_FLAGS:STRING=-static-libstdc++")
endif()
# 2025-07-23 master
set(CastXML_GIT_TAG 26cd570 CACHE STRING "CastXML Git revision.")
ExternalProject_Add(castxml
  GIT_REPOSITORY https://github.com/CastXML/CastXML.git
  GIT_TAG ${CastXML_GIT_TAG}
  DEPENDS ${castxml_deps}
  CMAKE_ARGS -Wno-dev
  CMAKE_GENERATOR "${CMAKE_GENERATOR}"
  CMAKE_CACHE_ARGS
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_CXX_STANDARD:STRING=${CMAKE_CXX_STANDARD}
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DLLVM_DIR:PATH=${LLVM_DIR}
    ${osx_args}
    ${linux_args}
  ${verbose_command}
  LOG_BUILD 0
  INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/castxml
  )
