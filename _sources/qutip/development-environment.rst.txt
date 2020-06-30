Creating a Development Environment
##################################

This page describes how to get a QuTiP development environment set up so that
you can begin contributing code, documentation or examples to QuTiP.  Please
stop by to talk to us either in the `QuTiP Google group`_ or in the issues page
on the `main QuTiP repository`_ if you have suggestions for new features, so we
can discuss the design and suitability with you.

To contribute to QuTiP development, you will need to have a working knowledge of
``git``.  If you're not familiar with it, you can read `GitHub's simple
introduction`_ or look at the official
`Git book <https://git-scm.com/book/en>`_ which also has the basics, but
then goes into much more detail if you're interested.

.. _QuTiP Google group: https://groups.google.com/forum/#!forum/qutip
.. _main QuTiP repository: https://github.com/qutip/qutip
.. _GitHub's simple introduction: https://guides.github.com/introduction/git-handbook


Requirements
============

To build ``qutip`` from source and to run the tests, you will need recent
versions of

- ``python`` (at least version 3.6)
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

   conda create -n qutip-dev python>=3.6 setuptools numpy scipy pytest Cython

This will create the virtual environment ``qutip-dev``, which you can then
switch to by using ``conda activate qutip-dev``.  Note that this does *not*
install any version of ``qutip``, because we will be building that from source.

.. note::
   You do not need to use ``conda``---any suitable virtual environment manager
   should work just fine.


Creating a Local Copy
=====================

At some point you will (hopefully) want to share your changes with us, so you
should fork the main repository on GitHub into your account, and then clone
that forked copy.  If you do not create a fork on GitHub, you will be able to
read and install QuTiP, but you will not be able to push any changes you make
back to GitHub so you can share them with us.

To create a fork, go to the relevant repository's page on GitHub (for example,
the main QuTiP repository is
`qutip/qutip on GitHub <https://github.com/qutip/qutip>`_), and click the fork
button in the top right.  This will create a linked version of the repository in
your own GitHub account.  GitHub also has `its own documentation on forking
<https://guides.github.com/activies/forking>`.

You can now "clone" your fork onto your local computer.  The command will look
something like ::

   git clone https://github.com/<user>/qutip

where ``<user>`` is your GitHub username (i.e. *not* ``qutip``).  This will
create a folder in your current directory called ``qutip`` which contains the
repository.  This is your *local copy*.

.. note::
   You can put your local copy wherever you like, and call the top-level
   directory whatever you like, including moving and renaming it after the
   ``clone`` operation.  As there is more than one QuTiP organisation
   repository, you may find it convenient to have ``qutip``, ``docs`` and
   ``notebooks`` all in a containing folder called ``qutip``.


Building From Source
====================

Make sure you have activated your QuTiP development virtual environment that you
set up earlier.  You should not have any version of QuTiP installed here.  If
you are in the root of the ``qutip`` repository (you should see the file
``setup.py``), then the command to build is ::

   python setup.py develop

If you need to test OpenMP support, add the flag ``--with-openmp`` to the end of
the command.

The ``develop`` target for
`setuptools <https://setuptools.readthedocs.io/en/latest/>`_ will compile and
link all of the Cython extensions, package the resulting files into an egg, and
add the package to the Python search path.  After you have done this, you should
be able to ``import qutip`` from anywhere as long as you have this development
environment active, and you will get your development environment.

.. note::
   In general, you do not need to re-run ``setup.py`` if you only make changes
   to the Python files.  These changes should appear immediately, when you
   re-import ``qutip`` albeit with the standard Python proviso that you may need
   to re-open the Python interpreter or use :func:`importlib.reload` to clear
   the package cache.

   If you make changes to any Cython files, you *must*
   re-run ``setup.py develop`` in the same manner, or your extensions will not
   be built.

You should now be able to run the tests.  From the root of the repository, or
inside ``qutip`` or ``qutip/tests``, you can simply run ``pytest`` to run
everything.  The full test suite will take about 20--30 minutes, depending on
your computer.  You can test specific files by passing them as arguments to
``pytest``, or you can use the ``-m "not slow"`` argument to disable some of the
slowest tests.


Contributing Code
=================

QuTiP development follows the "GitHub Flow" pattern of using Git.  This is a
simple triangular workflow, and you have already done the first step by creating
a fork.  In general, the process for contributing code follows a short list of
steps:

#. Fetch changes from the QuTiP organisation's copy
#. Create a new branch for your changes
#. Add commits with your changes to your new branch
#. Push your branch to your fork on GitHub
#. Make a pull request (PR) to the QuTiP repository

You can read more documentation about this pattern in the
`GitHub guide to Flow`_, and see
`the GitHub blog post
<https://github.blog/2015-07-29-git-2-5-including-multiple-worktrees-and-triangular-workflows/#improved-support-for-triangular-workflows>`_
about when the Git tool added greater support for this type of triangular work.

While using this pattern, you should keep your ``master`` branch looking the
same as ours, or at least you should not add any commits to it that we do not
have.  Always use topic branches, and do not merge them directly into
``master``.  Wait until your PR has been accepted and merged into our version,
then pull down the changes into your ``master`` branch.

To fetch changes from our copy, you will need to add our version (the repository
that you clicked "Fork" on) as a Git remote.  The base command is ::

   git remote add upstream https://github.com/qutip/qutip

This will add a remote called ``upstream`` to your local copy.  You will not
have write access to this, so you will not be able to push to it.  You will,
however, be able to fetch from it.  While on ``master``, do ::

   git pull upstream master

Unless you have made changes to your own version of ``master``, this will bring
you up-to-speed with ours.  To create and swap to a new branch to work on, use
::

   git checkout -b <branchname>

You can then swap branches by using ``git checkout <branchname>`` without the
``-b`` option.  To add commits to a branch, make the changes you want to make,
then call ::

   git add <file1> [<file2> ...]

on all the files you changed, and do ::

   git commit -m "<your message>"

to commit them.  Once you've made all the commits you want to make, push them to
your GitHub fork with ::

   git push -u origin

and make the PR using the GitHub web interface in the main QuTiP repository.



.. _GitHub guide to Flow: https::guides.github.com/introduction/flow
