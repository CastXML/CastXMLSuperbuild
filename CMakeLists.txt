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


  set(llvm_version 11.1.0)
  set(llvm_folder 11.1.0)
  set(llvm_md5 69bc06661ce8f1872e27b40ff96002b2)

  option(LLVM_OPENMP_SUPPORT "Add the flag to enable OpenMP support for LLVM?" OFF)
  if(LLVM_OPENMP_SUPPORT)
    set(openmp_version ${llvm_version})
    set(openmp_folder ${llvm_folder})
    set(openmp_args
	    -DLLVM_EXTERNAL_OPENMP_SOURCE_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR}/openmp-${openmp_version}.src
	    -DLLVM_EXTERNAL_CLANG_SOURCE_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR}/clang-${llvm_version}.src
	    -DLLVM_TOOL_OPENMP_BUILD:BOOL=ON)
    set(omp_src "openmp.tar.xz")
    file(DOWNLOAD https://github.com/llvm/llvm-project/releases/download/llvmorg-${openmp_folder}/openmp-${openmp_version}.src.tar.xz ${CMAKE_CURRENT_BINARY_DIR}/${omp_src} LOG omp_result)
  endif()

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
      ${openmp_args}
      ${osx_args}
    ${verbose_command}
    LOG_BUILD 0
    INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/llvm
    )

  if(LLVM_OPENMP_SUPPORT)
    ExternalProject_Add_Step(llvm openmp
      COMMAND ${CMAKE_COMMAND} -E tar xzf ${CMAKE_CURRENT_BINARY_DIR}/${omp_src}
      DEPENDERS configure
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      )
  endif()

  # Execution of download and unzip of clang moved here to
  # allow OpenMP to properly find Clang source code during LLVM compilation
  file(DOWNLOAD https://github.com/llvm/llvm-project/releases/download/llvmorg-${llvm_folder}/clang-${llvm_version}.src.tar.xz ${CMAKE_CURRENT_BINARY_DIR}/cfe-${llvm_version}.tar.xz STATUS clang_result)
  execute_process(COMMAND ${CMAKE_COMMAND} -E tar xzf ${CMAKE_CURRENT_BINARY_DIR}/cfe-${llvm_version}.tar.xz WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})

  set(clang_md5 133c6719e22bfded74fcaf1d3092e979)
  ExternalProject_Add(clang
    DEPENDS llvm
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/clang-${llvm_version}.src
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
set(CastXML_GIT_TAG v0.4.3 CACHE STRING "CastXML Git revision.")
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
