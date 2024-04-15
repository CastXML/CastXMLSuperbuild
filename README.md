# CastXML Superbuild

[![CI](https://github.com/CastXML/CastXMLSuperbuild/actions/workflows/ci.yml/badge.svg)](https://github.com/CastXML/CastXMLSuperbuild/actions/workflows/ci.yml)

This builds [CastXML](https://github.com/CastXML/CastXML) and its
dependencies (LLVM/Clang) with CMake\'s
[ExternalProject](http://www.cmake.org/cmake/help/git-master/module/ExternalProject.html)
module. It is a cross-platform way to build CastXML.

This can be built like any other [CMake](http://cmake.org) project. For
example:

    git clone https://github.com/CastXML/CastXMLSuperbuild.git
    mkdir CastXMLSuperbuild-build
    cd CastXMLSuperbuild-build
    cmake -GNinja ../CastXMLSuperbuild
    ninja

This requires [ninja](https://ninja-build.org/), which comes with recent
Visual Studio on Windows, can be installed on macOS with `brew install ninja`,
and can be installed with the `ninja-build` package in most Linux package
managers.

The resulting [castxml]{.title-ref} executable will be located at
[CastXMLSuperbuild-build/castxml/bin/castxml]{.title-ref}.

The resulting binary builds for Linux, Mac OSX, and Windows [are
available
here](https://data.kitware.com/#collection/57b5c9e58d777f126827f5a1/folder/57b5de948d777f10f2696370).
