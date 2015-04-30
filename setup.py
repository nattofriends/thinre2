from distutils.core import Extension
from distutils.core import setup

def ext(sources):
    return Extension(
        'thinre2',
        sources=sources,
        libraries=['re2'],
        language="c++",
    )


try:
    from Cython.Build import cythonize
    ext_modules = cythonize(
        ext(['thinre2.pyx']),
    )
except ImportError:
    ext_modules = [
        ext(['thinre2.cpp']),
    ]

setup(
    name='thinre2',
    version='0.1',
    description='Very thin Python wrapper for the RE2 library',
    author='Timmy Zhu <nattofriends@gmail.com>',
    ext_modules=ext_modules,
)

