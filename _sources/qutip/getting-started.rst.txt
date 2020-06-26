Getting Started
###############

This page describes how to get a QuTiP development environment set up so that
you can begin contributing code, documentation or examples to QuTiP.  Please
stop by to talk to us either in the `QuTiP Google group`_ or in the issues page
on the `main QuTiP repository`_ if you have suggestions for new features, so we
can discuss the design and suitability with you.

.. _QuTiP Google group: https://groups.google.com/forum/#!forum/qutip
.. _main QuTiP repository: https://github.com/qutip/qutip

.. note::
   Throughout this document, we will assume that you are using ``conda`` to
   manage Python environments.  This is not required so long as the general
   principles are followed, but all the examples will use ``conda``.


Requirements
============

To build ``qutip`` from source and to run the tests, you will need recent
versions of

- ``python`` (at least version 3.5)
- ``setuptools``
- ``numpy``
- ``scipy``
- ``pytest``
- ``Cython``

You will also need a working C++ compiler.  On Linux or Mac, there should
already be a suitable version of ``gcc`` or ``clang`` available, but on Windows
you will likely need to use a recent version of the Visual Studio compiler.

You should set up a separate virtual environment to house your development
version of QuTiP so it does not interfere with any other installation you might
have.  This can be done with ::

   conda create -n qutip-dev python>=3.5 setuptools numpy scipy pytest Cython

This will create the virtual environment ``qutip-dev``, which you can then
switch to by using ``conda activate qutip-dev``.  Note that this does *not*
install any version of ``qutip``, because we will be building that from source.


Creating a Fork
===============

At some point you will (hopefully) want to share your changes with us, so you
should fork the `main repository on GitHub`_ into your account, and then clone
that forked copy.

.. _main repository on GitHub: https://github.com/qutip/qutip

.. todo::
   Finish this page.
