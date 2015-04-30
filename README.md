# thinre2
Thin Cython bindings to re2

## Requirements
- Python 3 (tested with 3.4)
- RE2 library

Cython is required to recompile the extension from scratch.

## Example

    >>> import thinre2
    >>> re = thinre2.RE2('(a)(.)')
    >>> m = re.search('zzabzz')
    >>> list(m.groups())
    ['a', 'b']

## Caveats

These bindings were significantly slower than standard library `re` for my usage.

`RE2.match` isn't the same as `re.match`, it only succeeds if the text fully matches the pattern.
