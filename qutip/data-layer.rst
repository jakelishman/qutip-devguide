Data Layer
##########

The bulk of mathematical heavy lifting in QuTiP is handled by functions on the
"data layer".  The term "data layer" is used to refer to all linear algebra
types which QuTiP uses to represent low-level data, operations which take place
on these types, and the dispatch logic necessary to ensure that the correct
operations are called when given two abstract types.

All data types on the data layer inherit from :obj:`qutip.core.data.Data`,
although this is itself an abstract type which cannot be instantiated.
Dispatch functions are instances of the type :obj:`qutip.core.data.Dispatch`,
which provide a Python-callable interface.

The data layer is primarily written in Cython, and compiled to C++ before being
compiled fully into CPython extension types.


Why Not Just Use NumPy?
=======================

NumPy is a fantastic tool for representing numerical data, but it is limited to
dense matrices, while many operators in quantum mechanics are often much more
suited to a sparse representation.

For cases which *are* well-described by dense matrices, the data-layer type
:obj:`~qutip.core.data.Dense` is very similar to a NumPy array underneath (and
in fact can be directly viewed as one using its
:meth:`~qutip.core.data.Dense.as_array` method), but is guaranteed to hold
exactly two dimensions, of which one is stored contiguously.  These additional
internal guarantees help speed in the tightest loops, and the type can be
constructed very quickly from an :obj:`~numpy.ndarray` that is already in the
correct format.

For the large number of cases where the underlying data is much sparser, we use
the :obj:`qutip.core.data.CSR` type, which is a form of compressed sparse row
matrix very similar to SciPy's :obj:`scipy.sparse.csr_matrix`.  There are a few
reasons for not wanting to use SciPy's implementation:

#. Instantiation of :obj:`~scipy.sparse.csr_matrix` is very slow.
#. :obj:`~scipy.sparse.csr_matrix` can use different types as integer indices
   in its index arrays, but this can make it more difficult to interface with C
   code underneath.
#. QuTiP has many parts where very low-level C access is required, and having
   to always deal with Python types means that we must often hold the GIL and
   pay non-trivial overhead penalties when accessing Python attributes.

Older versions of QuTiP used to reduce these issues by using a
:class:`fast_csr_matrix` type which derived from
:obj:`~scipy.sparse.csr_matrix` and overrode its :meth:`!__init__` method to
remove the slow index-checking code and ensured that only data of the correct
types was stored.  In C-level code, a secondary struct :c:struct:`CSR_Matrix`
was defined, which led to various parts of the code have several entry points,
depending on how many of the arguments had been converted to the structure
representation, and there was still a lot of overhead in converting back to
Python-level code at the end.

The new :obj:`~qutip.core.data.CSR` type stores data in conceptually the same
manner as SciPy, but is defined purely at the Cython level.  This means that it
pays almost no overhead when switching between Python and C access, and code
working with the types need not hold the GIL.  Further, the internal storage
makes similar guarantees to the :obj:`~qutip.core.data.Dense` format about the
data storage, simplifying mathematical code within QuTiP.  It can also be
viewed as a SciPy object when it needs to be used from within Python.

Previous versions of QuTiP also *only* supported the :class:`fast_csr_matrix`
type as the backing data store.  There are many cases where this is a deeply
unsuitable type: in small systems, sparse matrices require large overheads and
stymie data caching, while even in large systems many operations produce
outputs which are nearly 100% dense such as time-evolution operators and matrix
exponentials.  For optimal control applications, the majority of the time spent
was just in dealing with the sparse overheads.  Allowing multiple types to
represent data lets us use the right tool for each job, but it does mean that
further care is taken to ensure that all the mathematical parts of the library
can function without needing to produce an exponential number of new
mathematical functions whenever a type or new operation is added.


Dispatch Operations
===================

.. todo::
   Still to write this section, in particular there's still some design parts
   that need to be ironed out.


Type Descriptions
=================

There are currently two first-class data types defined in QuTiP, but the
generic nature of the dispatch operations means that it is relatively
straightforward to add new types for specific use-cases.

Abstract Base: :obj:`~qutip.core.data.Data`
-------------------------------------------

The base :obj:`~qutip.core.data.Data` requires very little information to be
stored---only the two-dimensional shape of the matrix.  This is common to all
data types, and readable (but not writeable) from Python.


Compressed Sparse Row: :obj:`~qutip.core.data.CSR`
--------------------------------------------------

The `compressed sparse row format`_ has historically always been QuTiP's format
of choice.  Only non-zero data entries are stored, and information is kept
detailing how many stored entries are in each row, and which columns they
appear in.  This is one of the most common sparse matrix formats, having
minimal storage requirements for arbitrary sparse matrices, and perhaps most
importantly for linear algebra, it is especially suited for taking
matrix--vector products.

QuTiP's implementation stores all indexing types as the centrally defined
:c:type:`~qutip.core.data.idxint` type, which is fixed at compile time.
Typically this will be a 32- or 64-bit integer, and we generally use signed
arithmetic to be consistent with Python indexing (although we do actually allow
negative indexing into C arrays).  All variables which are used to index into
an array should follow this type within C or Cython code.

:obj:`~qutip.core.data.CSR` can be instantiated from Python in similar ways to
SciPy's :obj:`~scipy.sparse.csr_matrix`, but it also provides fast-path
initialisation from Python or C using the type's
:meth:`~qutip.core.data.CSR.copy` method, or the low-level constructors
:obj:`~qutip.core.data.csr.empty`, :obj:`~qutip.core.data.csr.zeroes`,
:obj:`~qutip.core.data.csr.identity`, and 
:obj:`~qutip.core.data.csr.copy_structure`.

.. _compressed sparse row format: https://en.wikipedia.org/wiki/Sparse_matrix#Compressed_sparse_row_(CSR,_CRS_or_Yale_format)


Access From Python
..................

We do not expose the underlying memory buffers to the user in Python space by
default.  This is to avoid needing to acquire the GIL every time one of our
objects is created, especially when C code creates several of them in a
function which otherwise would not need to speak to the Python interpreter at
all.

Instead, we expose a method :meth:`~qutip.core.data.CSR.as_scipy`, which
returns a :obj:`~scipy.sparse.csr_matrix`.  So that the Python-space user can
work with the data if they desire, this output is simply a "view" onto the same
underlying data buffers.  This has some memory management implications that
will be discussed in the next section.

The problem of :obj:`~scipy.sparse.csr_matrix` having a slow constructor still
persists, however.  We do not want to have to define a whole new derived class
(like the old :class:`fast_csr_matrix`) just to override :meth:`!__init__`,
mostly because it's unnecessary and bloats our own code, but it also may have
annoying knock-on effects for users with imperfect polymorphic code and it adds
overhead to method resolution.  Instead, we simply allocate space for a
:obj:`~scipy.sparse.csr_matrix` with its
:meth:`~scipy.sparse.csr_matrix.__new__` method, call the first reasonable
method in the initialisation chain, and fill in the rest in Cython code.
Because of the guarantees about the :obj:`~qutip.core.data.CSR` type, we know
that our data will already be in the correct format.

We then store a reference to this object within :obj:`~qutip.core.data.CSR` so
that subsequent calls do not need to pay the initialisation penalty.  This also
helps with memory management.


Memory Management
.................

When constructed from Python, :obj:`~qutip.core.data.CSR` does not take
ownership of its memory since we know we already have to be dealing with
refcounting and the GIL.  We use NumPy's access methods to construct new
arrays, and let NumPy handle management of the data.

However, when constructed from Cython code, including Cython functions called
by Python, there is no need to interface with NumPy or create Python objects
other the very last instance when we have to return it to the user in Python
space.  Here we use low-level C memory management, and rely on the general
principle of low-level QuTiP development that *you must not store references to
other objects' data*.  Other libraries allow this, but instead require that you
suitably increment the relevant refcounts.  We do not keep track of anything
like this, and simply do not permit references in this manner within our code.

Sometimes, however, the user will need to access the data directly from Python
space.  In these cases, we must ensure that the data buffer cannot be freed
while the user holds a reference to it.  We allow the user to use the
:meth:`~qutip.core.data.CSR.as_scipy` method to view the data, and as part of
this process, we create new a :obj:`~numpy.ndarray` for each buffer, and set
the :c:data:`NPY_ARRAY_OWNDATA` flag to force NumPy to manage reference
counting for us.

Since we have just passed on ownership of our data to another entity, we always
keep a (strong) reference to the created object within our own type.  This was
we can guarantee that NumPy will not deallocate our storage before we are done
with it, and NumPy's memory management will also ensure that the memory *is*
deallocated safely once all Python views onto it are gone.

It is important when allocating buffers which may become the backing of a
:obj:`~qutip.core.data.CSR` type that you *always* use
:c:func:`PyDataMem_NEW` (or others in the ``PyDataMem`` family) and
:c:func:`PyDataMem_FREE` to allocate and free memory.  Doing
otherwise may cause segfaults or other complete interpreter crashes, as it may
not use the same allocator that NumPy does.  In particular, the Windows runtime
can easily result in this happening if raw ``malloc`` or ``calloc`` are used,
and the CPython allocator :c:func:`!cpython.mem.PyMem_Malloc` will tend to
allocate small requests into an internal reserved buffer on its stack, which
cannot be freed from NumPy.


Dense: :obj:`~qutip.core.data.Dense`
------------------------------------

.. todo::
   Add some information about this class.
