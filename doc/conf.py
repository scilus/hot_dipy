# dipy documentation build configuration file, created by
# sphinx-quickstart on Thu Feb  4 15:23:20 2010.
#
# This file is execfile()d with the current directory set to its containing dir.
#
# Note that not all possible configuration values are present in this
# autogenerated file.
#
# All configuration values have a default; values that are commented out
# serve to show the default.

import os
import re
import sys
import ablog
import json

# Doc generation depends on being able to import dipy
try:
    import dipy
except ImportError:
    raise RuntimeError('Cannot import dipy, please investigate')

from packaging.version import Version
import sphinx
if Version(sphinx.__version__) < Version('2'):
    raise RuntimeError('Need sphinx >= 2 for numpydoc to work correctly')

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
sys.path.append(os.path.abspath('sphinxext'))

# -- General configuration -----------------------------------------------------

# We load the nibabel release info into a dict by explicit execution
rel = {}
with open(os.path.join('..', 'dipy', 'info.py')) as f:
    exec(f.read(), rel)


# Add any Sphinx extension module names here, as strings. They can be extensions
# coming with Sphinx (named 'sphinx.ext.*') or your custom ones.
extensions = ['sphinx.ext.autodoc',
              'sphinx.ext.doctest',
              'sphinx.ext.intersphinx',
              'sphinx.ext.todo',
              'sphinx.ext.coverage',
              'sphinx.ext.mathjax',
              'sphinx.ext.ifconfig',
              'sphinx.ext.autosummary',
              'prepare_gallery',
              'math_dollar',  # has to go before numpydoc
              'sphinx_gallery.gen_gallery',
            #   'numpydoc',
              'github',
              'ablog',
              'jinja'
]

# Providing different contexts for the jinja directive
jinja_contexts = {
    "documentation": json.load(open("./context/documentation.json"))
}

numpydoc_show_class_members = True
numpydoc_class_members_toctree = False

# ghissue config
github_project_url = "https://github.com/dipy/dipy"

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# The suffix of source filenames.
source_suffix = '.rst'

# The encoding of source files.
#source_encoding = 'utf-8'

# The master toctree document.
master_doc = 'index'

# General information about the project.
project = 'dipy'
copyright = '2008-2023, %(AUTHOR)s <%(AUTHOR_EMAIL)s>' % rel

# The version info for the project you're documenting, acts as replacement for
# |version| and |release|, also used in various other places throughout the
# built documents.
#
# The short X.Y version.
version = rel['__version__']
# The full version, including alpha/beta/rc tags.
release = version

# Include common links
# We don't use this any more because it causes conflicts with the gitwash docs
#rst_epilog = open('links_names.inc', 'rt').read()

# The language for content autogenerated by Sphinx. Refer to documentation
# for a list of supported languages.
#language = None

# There are two options for replacing |today|: either, you set today to some
# non-false value, then it is used:
#today = ''
# Else, today_fmt is used as the format for a strftime call.
#today_fmt = '%B %d, %Y'

# List of documents that shouldn't be included in the build.
#unused_docs = []

# List of directories, relative to source directory, that shouldn't be searched
# for source files.
exclude_patterns = ['_build', 'examples', 'examples_revamped']

# The reST default role (used for this markup: `text`) to use for all documents.
#default_role = None

# If true, '()' will be appended to :func: etc. cross-reference text.
#add_function_parentheses = True

# If true, the current module name will be prepended to all description
# unit titles (such as .. function::).
#add_module_names = True

# If true, sectionauthor and moduleauthor directives will be shown in the
# output. They are ignored by default.
#show_authors = False

# The name of the Pygments (syntax highlighting) style to use.
pygments_style = 'sphinx'

# A list of ignored prefixes for module index sorting.
#modindex_common_prefix = []


# -- Options for HTML output ---------------------------------------------------

# The theme to use for HTML and HTML Help pages.  Major themes that come with
# Sphinx are currently 'default' and 'sphinxdoc'.
html_theme = "pydata_sphinx_theme"

# The style sheet to use for HTML and HTML Help pages. A file of that name
# must exist either in Sphinx' static/ path, or in one of the custom paths
# given in html_static_path.
html_style = 'css/dipy.css'

# Theme options are theme-specific and customize the look and feel of a theme
# further.  For a list of options available for each theme, see the
# documentation.
html_theme_options = {
  "secondary_sidebar_items": ["page-toc"],
  "show_toc_level": 2
}

# Add any paths that contain custom themes here, relative to this directory.
#html_theme_path = []

# The name for this set of Sphinx documents.  If None, it defaults to
# "<project> v<release> documentation".
#html_title = None

# A shorter title for the navigation bar.  Default is the same as html_title.
#html_short_title = None

# The name of an image file (relative to this directory) to place at the top
# of the sidebar.
#html_logo = None

# The name of an image file (within the static path) to use as favicon of the
# docs.  This file should be a Windows icon file (.ico) being 16x16 or 32x32
# pixels large.
#html_favicon = None

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['_static']

# If not '', a 'Last updated on:' timestamp is inserted at every page bottom,
# using the given strftime format.
#html_last_updated_fmt = '%b %d, %Y'

# If true, SmartyPants will be used to convert quotes and dashes to
# typographically correct entities.
#html_use_smartypants = True

# Custom sidebar templates, maps document names to template names.
#html_sidebars = {'index': 'indexsidebar.html'}

# Additional templates that should be rendered to pages, maps page names to
# template names.
#html_additional_pages = {}

# If false, no module index is generated.
# Setting to false fixes double module listing under header
html_use_modindex = False

# If false, no index is generated.
#html_use_index = True

# If true, the index is split into individual pages for each letter.
#html_split_index = False

# If true, links to the reST sources are added to the pages.
#html_show_sourcelink = True

# If true, an OpenSearch description file will be output, and all pages will
# contain a <link> tag referring to it.  The value of this option must be the
# base URL from which the finished HTML is served.
#html_use_opensearch = ''

# If nonempty, this is the file name suffix for HTML files (e.g. ".xhtml").
#html_file_suffix = ''

# Output file base name for HTML help builder.
htmlhelp_basename = 'dipydoc'


# -- Options for LaTeX output --------------------------------------------------

# The paper size ('letter' or 'a4').
#latex_paper_size = 'letter'

# The font size ('10pt', '11pt' or '12pt').
#latex_font_size = '10pt'

# Grouping the document tree into LaTeX files. List of tuples
# (source start file, target name, title, author, documentclass [howto/manual]).
latex_documents = [
  ('index', 'dipy.tex', 'dipy Documentation',
   'Eleftherios Garyfallidis, Ian Nimmo-Smith, Matthew Brett', 'manual'),
]

# The name of an image file (relative to this directory) to place at the top of
# the title page.
#latex_logo = None

# For "manual" documents, if this is true, then toplevel headings are parts,
# not chapters.
#latex_use_parts = False

# Additional stuff for the LaTeX preamble.
latex_preamble = r"""
\usepackage{amsfonts}
"""

# Documents to append as an appendix to all manuals.
#latex_appendices = []

# If false, no module index is generated.
#latex_use_modindex = True


# -- Options for sphinx gallery -------------------------------------------
from docimage_scrap import ImageFileScraper
from sphinx_gallery.sorting import ExplicitOrder
from prepare_gallery import folder_explicit_order

sc = ImageFileScraper()
ordered_folders = [f'examples_revamped/{f}' for f in folder_explicit_order()]

sphinx_gallery_conf = {
     'doc_module': ('dipy',),
     # path to your examples scripts
     'examples_dirs': ['examples_revamped', ],
     # path where to save gallery generated examples
    #  'gallery_dirs': ['examples_built', ],
     'subsection_order': ExplicitOrder(ordered_folders),
     'image_scrapers': (sc),
     'backreferences_dir': 'examples_built',
     'reference_url': {'dipy': None, },
     'abort_on_example_error': False,
     'filename_pattern': re.escape(os.sep),
     'default_thumb_file': '_static/dipy-logo.png',
     'pypandoc': {'extra_args': ['--mathjax',]},
}

# Example configuration for intersphinx: refer to the Python standard library.
intersphinx_mapping = {'http://docs.python.org/': None}

