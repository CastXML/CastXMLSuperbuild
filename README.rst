CastXML Superbuild
==================

.. image:: https://circleci.com/gh/thewtex/CastXMLSuperbuild.svg?style=svg
    :target: https://circleci.com/gh/thewtex/CastXMLSuperbuild

This builds CastXML_ and its dependencies (LLVM/Clang) with CMake's
ExternalProject_ module. It is a cross-platform way to build CastXML.

This can be built like any other CMake_ project.  For example::

  git clone https://github.com/thewtex/CastXMLSuperbuild.git
  mkdir CastXMLSuperbuild-build
  cd CastXMLSuperbuild-build
  cmake ../CastXMLSuperbuild
  make

The resulting `castxml` executable will be located at
`CastXMLSuperbuild-build/castxml/bin/castxml`.

Binary builds for Linux are available in the
`CircleCI artifacts https://circleci.com/gh/thewtex/CastXMLSuperbuild`_.

.. _CastXML: https://github.com/CastXML/CastXML
.. _ExternalProject: http://www.cmake.org/cmake/help/git-master/module/ExternalProject.html
.. _CMake: http://cmake.org
