from distutils.core import setup, Extension

module1 = Extension('rec',
                    sources = ['src/recmodule.c'])

setup (name = 'rec',
       version = '0.1',
       description = 'This is a rec demo package',
       ext_modules = [module1])
