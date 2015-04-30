# -*- coding: utf-8 -*-
# cython: c_string_type=unicode, c_string_encoding=utf8

cimport _re2
from cython.operator cimport dereference as deref
from libc.stdlib cimport free
from libc.stdlib cimport calloc
from libcpp cimport bool
from libcpp.string cimport string
from libcpp.vector cimport vector

cdef class Options:
    cdef _re2.Options *wrapped

    def __cinit__(self):
        self.wrapped = new _re2.Options()
        self.log_errors = False

    property posix_syntax:
        def __get__(self): return self.wrapped.posix_syntax()
        def __set__(self, bint val): self.wrapped.set_posix_syntax(val)

    property longest_match:
        def __get__(self): return self.wrapped.longest_match()
        def __set__(self, bint val): self.wrapped.set_longest_match(val)

    property log_errors:
        def __get__(self): return self.wrapped.log_errors()
        def __set__(self, bint val): self.wrapped.set_log_errors(val)

    property max_mem:
        def __get__(self): return self.wrapped.max_mem()
        def __set__(self, int val): self.wrapped.set_max_mem(val)

    property literal:
        def __get__(self): return self.wrapped.literal()
        def __set__(self, bint val): self.wrapped.set_literal(val)

    property never_nl:
        def __get__(self): return self.wrapped.never_nl()
        def __set__(self, bint val): self.wrapped.set_never_nl(val)

    property dot_nl:
        def __get__(self): return self.wrapped.dot_nl()
        def __set__(self, bint val): self.wrapped.set_dot_nl(val)

    property case_sensitive:
        def __get__(self): return self.wrapped.case_sensitive()
        def __set__(self, bint val): self.wrapped.set_case_sensitive(val)

    property perl_classes:
        def __get__(self): return self.wrapped.perl_classes()
        def __set__(self, bint val): self.wrapped.set_perl_classes(val)

    property word_boundary:
        def __get__(self): return self.wrapped.word_boundary()
        def __set__(self, bint val): self.wrapped.set_word_boundary(val)

    property one_line:
        def __get__(self): return self.wrapped.one_line()
        def __set__(self, bint val): self.wrapped.set_one_line(val)


cdef class RE2:
    cdef _re2.RE2 *wrapped

    cdef vector[_re2.Arg] *argv
    cdef vector[_re2.ArgPtr] *argp

    def __cinit__(self, unicode pattern, Options options=None):
        # Force some options so it doesn't print itself to stderr
        cdef string pattern_encoded = pattern.encode('UTF-8')
        sp = new _re2.StringPiece(pattern_encoded)

        if not options:
            options = Options()

        self.wrapped = new _re2.RE2(
            deref(sp),
            deref(options.wrapped),
        )

        if not self.ok():
            raise ValueError(self.error())

        self.argv = new vector[_re2.Arg]()
        self.argp = new vector[_re2.ArgPtr]()

    def __dealloc__(self):
        del self.wrapped, self.argv, self.argp

    def ok(self):
        return self.wrapped.ok()

    def error(self):
        return self.wrapped.error()

    def error_code(self):
        return self.wrapped.error_code()

    def pattern(self):
        return self.wrapped.pattern()

    def search(self, unicode text):
        return self._search(text, full_match=False)

    def match(self, unicode text):
        """This is slightly lying as re.match means that the pattern matches
        from the beginning of the string. RE2.FullMatchN demands however
        that the entire string match the entire pattern.
        Dealing with this is left as an exercise to the reader.
        """
        return self._search(text, full_match=True)

    cdef _search(self, unicode text, full_match):
        cdef string text_encoded = text.encode('UTF-8')
        cdef _re2.StringPiece *input = new _re2.StringPiece(text_encoded)
        num_groups = self.wrapped.NumberOfCapturingGroups()

        # We really only need the matches after we leave scope here
        # Furthermore, something seems to be bungling the underlying string
        # and it is much too late. So we will stuff them in sts::strings.
        self.argv.resize(num_groups)
        self.argp.resize(num_groups)
        cdef vector[string] *matches = new vector[string](num_groups)

        # re2 has a silly interface for parameters.
        for i in range(num_groups):
            deref(self.argp)[i] = &deref(self.argv)[i]
            deref(self.argv)[i] = <_re2.Arg>&deref(matches)[i]

        if full_match:
            result = self.wrapped.FullMatchN(
                deref(input),
                deref(self.wrapped),
                &(deref(self.argp)[0]),
                num_groups,
            )
        else:
            result = self.wrapped.PartialMatchN(
                deref(input),
                deref(self.wrapped),
                &(deref(self.argp)[0]),
                num_groups,
            )

        del input

        if result:
            result = ResultFactory(matches)
            return result
        else:
            return None


cdef Result ResultFactory(vector[string] *matches):
    cdef Result result = Result()
    result.matches = matches
    return result


cdef class Result:
    cdef vector[string] *matches

    def __dealloc__(self):
        del self.matches

    def groups(self):
        matches = deref(self.matches)
        return (
            matches[i]
            for i in range(matches.size())
        )

