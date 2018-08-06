CastXML Superbuild
==================

.. image:: https://circleci.com/gh/CastXML/CastXMLSuperbuild.svg?style=shield
    :target: https://circleci.com/gh/CastXML/CastXMLSuperbuild

.. image:: https://travis-ci.org/CastXML/CastXMLSuperbuild.svg?branch=master
    :target: https://travis-ci.org/CastXML/CastXMLSuperbuild

This builds CastXML_ and its dependencies (LLVM/Clang) with CMake's
ExternalProject_ module. It is a cross-platform way to build CastXML.

This can be built like any other CMake_ project.  For example::

  git clone https://github.com/CastXML/CastXMLSuperbuild.git
  mkdir CastXMLSuperbuild-build
  cd CastXMLSuperbuild-build
  cmake ../CastXMLSuperbuild
  make

The resulting `castxml` executable will be located at
`CastXMLSuperbuild-build/castxml/bin/castxml`.

The resulting binary builds for Linux, Mac OSX, and Windows `are available here <https://data.kitware.com/#collection/57b5c9e58d777f126827f5a1/folder/57b5de948d777f10f2696370>`_.

.. _CastXML: https://github.com/CastXML/CastXML
.. _ExternalProject: http://www.cmake.org/cmake/help/git-master/module/ExternalProject.html
.. _CMake: http://cmake.org
