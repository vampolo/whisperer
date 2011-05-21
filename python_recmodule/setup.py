from distutils.core import setup, Extension

recmodule = Extension('rec',
					define_macros=[('MAJOR_VERSION', '1'),
								   ('MINOR_VERSION', '0')],
					include_dirs = ['include'],
					extra_objects = ['libAlg.so'],
                    sources = ['src/recmodule.c']
                    )

setup (name = 'rec',
       version = '0.1',
       description = 'This module wrappers matlab recommendation functions to python',
       ext_modules = [recmodule])
