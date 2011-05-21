from distutils.core import setup, Extension

recmodule = Extension('rec',
                    sources = ['src/recmodule.c'])

setup (name = 'rec',
       version = '0.1',
       description = 'This module wrappers matlab recommendation functions to python',
       ext_modules = [recmodule])
