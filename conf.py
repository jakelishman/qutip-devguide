project = "QuTiP Developers' Guide"
copyright = '2020, QuTiP developers'
author = 'Jake Lishman'
version = '5.0'
release = '5.0.0alpha1'

extensions = [
    'sphinx.ext.intersphinx',
    'sphinx.ext.todo',
]

intersphinx_mapping = {
    'qutip': ('http://qutip.org/docs/latest/', None),
    'python': ('https://docs.python.org/3', None),
    'numpy': ('https://numpy.org/doc/stable/', None),
    'scipy': ('https://docs.scipy.org/doc/scipy/reference/', None),
    'cython': ('https://cython.readthedocs.io/en/latest/', None),
}

todo_include_todos = True

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

html_theme = 'sphinx_rtd_theme'
html_static_path = ['_static']
html_extra_path = ['.nojekyll']
