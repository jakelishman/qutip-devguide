project = "QuTiP Developers' Guide"
copyright = '2020, QuTiP developers'
author = 'Jake Lishman'
release = '5.0.0alpha1'

extensions = [
    'sphinx.ext.intersphinx',
]

intersphinx_mapping = {
    'qutip': ('http://qutip.org/docs/latest', None),
}

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

html_theme = 'alabaster'
html_static_path = ['_static']
