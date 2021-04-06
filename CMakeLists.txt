cmake_minimum_required(VERSION 3.10)

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


# Use a static runtime with MSVC
if(MSVC)
  foreach(flag
    CMAKE_CXX_FLAGS
    CMAKE_CXX_FLAGS_RELEASE
    CMAKE_C_FLAGS
    CMAKE_C_FLAGS_RELEASE
    )
    if(${flag} MATCHES "/MD")
      string(REGEX REPLACE "/MD" "/MT" ${flag} "${${flag}}")
    endif()
  endforeach()
else()
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14")
endif()


if(APPLE)
  set(osx_args
    -DCMAKE_OSX_DEPLOYMENT_TARGET:STRING=10.9
    -DCMAKE_OSX_ARCHITECTURES:STRING=x86_64
    )
endif()


include(ExternalProject)

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

  set(llvm_version 11.0.0rc3)
  set(llvm_folder 11.0.0-rc3)
  set(llvm_md5 298943e26930ad58253d40edae0df771)
  ExternalProject_Add(llvm
    URL https://github.com/llvm/llvm-project/releases/download/llvmorg-${llvm_folder}/llvm-${llvm_version}.src.tar.xz
    URL_MD5 ${llvm_md5}
    CMAKE_ARGS -Wno-dev
    CMAKE_GENERATOR "${CMAKE_GENERATOR}"
    CMAKE_CACHE_ARGS
      -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
      "-DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS} -w"
      "-DCMAKE_CXX_FLAGS_RELEASE:STRING=${CMAKE_CXX_FLAGS_RELEASE}"
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
      "-DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS} -w"
      "-DCMAKE_C_FLAGS_RELEASE:STRING=${CMAKE_C_FLAGS_RELEASE}"
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
      -DLLVM_USE_CRT_RELEASE:STRING=MT
      -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
      -DLLVM_ENABLE_TERMINFO:BOOL=OFF
      -DLLVM_INCLUDE_TESTS:BOOL=OFF
      -DLLVM_INCLUDE_EXAMPLES:BOOL=OFF
      -DLLVM_INCLUDE_DOCS:BOOL=OFF
      -DLLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN:BOOL=ON
      ${osx_args}
    ${verbose_command}
    LOG_BUILD 0
    INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/llvm
    )


  set(clang_md5 242b25bbd11f19752198e4bad70cc20c)
  ExternalProject_Add(clang
    URL https://github.com/llvm/llvm-project/releases/download/llvmorg-${llvm_folder}/clang-${llvm_version}.src.tar.xz
    URL_MD5 ${clang_md5}
    DEPENDS llvm
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/cfe-${llvm_version}
    CMAKE_ARGS -Wno-dev
    CMAKE_GENERATOR "${CMAKE_GENERATOR}"
    CMAKE_CACHE_ARGS
      -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
      "-DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS} -w"
      "-DCMAKE_CXX_FLAGS_RELEASE:STRING=${CMAKE_CXX_FLAGS_RELEASE}"
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
      "-DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS} -w"
      "-DCMAKE_C_FLAGS_RELEASE:STRING=${CMAKE_C_FLAGS_RELEASE}"
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
      -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
      -DCLANG_INCLUDE_DOCS:BOOL=OFF
      -DCLANG_INCLUDE_TESTS:BOOL=OFF
      -DLLVM_CONFIG:PATH=${CMAKE_CURRENT_BINARY_DIR}/llvm/bin/llvm-config
      -DLLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN:BOOL=ON
      ${osx_args}
    ${verbose_command}
    LOG_BUILD 0
    INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/llvm
    )

  set(castxml_deps llvm clang)
  set(LLVM_DIR ${CMAKE_CURRENT_BINARY_DIR}/llvm/lib/cmake/llvm/)
endif()


# Use a static C++ library on GCC/Linux
if(CMAKE_COMPILER_IS_GNUCXX AND CMAKE_SYSTEM_NAME MATCHES "Linux")
  set(extra_flags "-static-libstdc++")
endif()
# 2020-09-22 master
set(CastXML_GIT_TAG v0.4.2 CACHE STRING "CastXML Git revision.")
ExternalProject_Add(castxml
  GIT_REPOSITORY https://github.com/CastXML/CastXML.git
  GIT_TAG ${CastXML_GIT_TAG}
  DEPENDS ${castxml_deps}
  CMAKE_ARGS -Wno-dev
  CMAKE_GENERATOR "${CMAKE_GENERATOR}"
  CMAKE_CACHE_ARGS
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    "-DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS} -w ${extra_flags}"
    "-DCMAKE_CXX_FLAGS_RELEASE:STRING=${CMAKE_CXX_FLAGS_RELEASE}"
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    "-DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS} -w"
    "-DCMAKE_C_FLAGS_RELEASE:STRING=${CMAKE_C_FLAGS_RELEASE}"
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DLLVM_DIR:PATH=${LLVM_DIR}
    ${osx_args}
  ${verbose_command}
  LOG_BUILD 0
  INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/castxml
  )
