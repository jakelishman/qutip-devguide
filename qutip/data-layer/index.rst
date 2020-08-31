Data Layer
##########

The bulk of mathematical heavy lifting in QuTiP is handled by functions on the
"data layer".  The term "data layer" is used to refer to all linear algebra
types which QuTiP uses to represent low-level data, operations which take place
on these types, and the dispatch logic necessary to ensure that the correct
operations are called when given two arbitrary, known types.

All data types on the data layer inherit from :obj:`qutip.core.data.Data`,
although this is itself an abstract type which cannot be instantiated.
Dispatch functions are instances of the type :obj:`qutip.core.data.Dispatch`,
which provide a Python-callable interface.

The data layer is primarily written in Cython, and compiled to C++ before being
compiled fully into CPython extension types.


.. toctree::
   :maxdepth: 2
   :caption: Sections

   terminology
   motivation
   type-conversion
   dispatch
   types
