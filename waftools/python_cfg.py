# coding=utf-8

import sys
import os
import os.path as osp
from functools import partial
from subprocess import Popen, PIPE
from distutils.version import LooseVersion

from waflib import Options, Configure, Errors, Utils

def options(self):
    self.load('python')    # --nopyc/--nopyo are enabled below
    group = self.add_option_group('Code_Aster options')
    group.add_option('--embed-python', dest='embed_python',
                    default=False, action='store_true',
                    help='Embed python as static libraries (experimental, '
                         'not enabled by embed-all)')

def configure(self):
    self.check_system_libs()
    self.configure_pythonpath()
    # require to force static libs if --embed-python is present
    embed_py = self.options.embed_python
    if embed_py:
        self.static_lib_pref()
    self.check_python()
    self.check_numpy()
    if embed_py:
        self.revert_lib_pref()
        if self.env['LIB_PYEMBED']:
            self.env['STLIB_PYEMBED'] = self.env['LIB_PYEMBED']
            del self.env['LIB_PYEMBED']

###############################################################################
@Configure.conf
def check_system_libs(self):
    """check for system libs"""
    # may be required for non-system python installation (never in static)
    self.check_cc(uselib_store='PYEMBED', lib='pthread', mandatory=False)
    self.check_cc(uselib_store='PYEMBED', lib='dl', mandatory=False)
    self.check_cc(uselib_store='PYEMBED', lib='util', mandatory=False)

@Configure.conf
def configure_pythonpath(self):
    """Insert env.PYTHONPATH at the beginning of sys.path"""
    path = Utils.to_list(self.env['PYTHONPATH'])
    system_path = _get_default_pythonpath()
    for i in sys.path:
        if i in system_path:
            continue
        if osp.basename(i).startswith('.waf'):
            continue
        if osp.abspath(i).startswith(osp.abspath(os.getcwd())):
            continue
        path.append(i)
    sys.path = path + sys.path
    self.env['CFG_PYTHONPATH'] = path
    os.environ['PYTHONPATH'] = os.pathsep.join(sys.path)

@Configure.conf
def check_python(self):
    self.load('python')
    self.check_python_version((2, 7, 0))
    self.check_python_headers()

@Configure.conf
def check_numpy(self):
    self.check_numpy_module()
    self.check_numpy_version((1, 4, 0))
    self.check_numpy_headers()

@Configure.conf
def check_numpy_module(self):
    if not self.env['PYTHON']:
        self.fatal('load python tool first')
    # getting python module
    self.start_msg('Checking for numpy')
    self.check_python_module('numpy')
    self.end_msg('yes')

@Configure.conf
def check_numpy_headers(self):
    if not self.env['PYTHON']:
        self.fatal('load python tool first')
    self.start_msg('Checking for numpy include')
    # retrieve includes dir from numpy module
    numpy_includes = self.get_python_variables(
        ['"\\n".join(misc_util.get_numpy_include_dirs())'],
        ['from numpy.distutils import misc_util'])
    # check the given includes dirs
    self.check(
                     feature = 'c',
                 header_name = 'Python.h numpy/arrayobject.h',
                    includes = numpy_includes,
                     defines = 'NPY_NO_PREFIX',
                         use = ['PYEMBED'],
                uselib_store = 'NUMPY',
        errmsg='Could not find the numpy development headers'
    )
    self.end_msg(numpy_includes)

@Configure.conf
def check_numpy_version(self, minver=None):
    """Check if the numpy module is found matching a given minimum version.
    minver should be a tuple, eg. to check for numpy >= 1.4 pass (1,4,0) as minver.
    """
    if not self.env['PYTHON']:
        self.fatal('load python tool first')
    assert isinstance(minver, tuple)
    cmd = self.env['PYTHON'] + ['-c', 'import numpy; print(numpy.__version__)']
    res = self.cmd_and_log(cmd)
    npyver = res.strip()
    if minver is None:
        self.msg('Checking for numpy version', npyver)
        return
    minver_str = '.'.join(map(str, minver))
    result = LooseVersion(npyver) >= LooseVersion(minver_str)
    self.msg('Checking for numpy version', npyver, ">= %s" % (minver_str,) and 'GREEN' or 'YELLOW')

    if not result:
        self.fatal('The NumPy version is too old, expecting %r' % (minver,))

@Configure.conf
def check_optimization_python(self):
    self.setenv('debug')
    self.env['PYC'] = self.env['PYO'] = 0
    self.setenv('release')
    self.env['PYC'] = self.env['PYO'] = 0

def _get_default_pythonpath():
    """Default sys.path should be added into PYTHONPATH"""
    env = os.environ.copy()
    env['PYTHONPATH'] = ''
    proc = Popen([sys.executable, '-c', 'import sys; print sys.path'],
                 stdout=PIPE, env=env)
    system_path = eval(proc.communicate()[0])
    return system_path
