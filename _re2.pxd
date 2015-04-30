# -*- coding: utf-8 -*-

from libcpp cimport bool
from libcpp.map cimport map
from libcpp.string cimport string

cdef extern from "re2/stringpiece.h" namespace "re2":
    cdef cppclass StringPiece:
        # Eliding some constructors on purpose.
        StringPiece(const char*) except +
        StringPiece(const string&) except +

        const char* data()
        int length()

ctypedef Arg* ArgPtr

cdef extern from "re2/re2.h" namespace "re2":
    cdef cppclass Arg "RE2::Arg":
        Arg()


    cdef cppclass RE2:
        RE2(const char*) except +
        RE2(const StringPiece&) except +
        RE2(const StringPiece&, const Options&) except +

        const map[int, string]& CapturingGroupNames() const
        const map[string, int]& NamedCapturingGroups() const
        int NumberOfCapturingGroups() const

        string error() const
        ErrorCode error_code() const
        bint ok() const
        const string pattern() const

        @staticmethod
        bint PartialMatchN(
            const StringPiece&,
            const RE2&,
            const Arg* const args[],
            int,
        )

        @staticmethod
        bint FullMatchN(
            const StringPiece&,
            const RE2&,
            const Arg* const args[],
            int,
        )


    cdef cppclass Options "RE2::Options":
        Options()

        bint posix_syntax() const
        void set_posix_syntax(bint)
        bint longest_match() const
        void set_longest_match(bint)
        bint log_errors() const
        void set_log_errors(bint)
        int max_mem() const
        void set_max_mem(int)
        bint literal() const
        void set_literal(bint)
        bint never_nl() const
        void set_never_nl(bint)
        bint dot_nl() const
        void set_dot_nl(bint)
        bint case_sensitive() const
        void set_case_sensitive(bint)
        bint perl_classes() const
        void set_perl_classes(bint)
        bint word_boundary() const
        void set_word_boundary(bint)
        bint one_line() const
        void set_one_line(bint)

    cdef enum Anchor:
        UNANCHORED "RE2::UNANCHORED"
        ANCHOR_START "RE2::ANCHOR_START"
        ANCHOR_BOTH "RE2::ANCHOR_BOTH"

    cdef enum ErrorCode:
        NoError "RE2::NoError"
        ErrorInternal "RE2::ErrorInternal"
        # Parse errors
        ErrorBadEscape "RE2::ErrorBadEscape"          # bad escape sequence
        ErrorBadCharClass "RE2::ErrorBadCharClass"       # bad character class
        ErrorBadCharRange "RE2::ErrorBadCharRange"       # bad character class range
        ErrorMissingBracket "RE2::ErrorMissingBracket"     # missing closing ]
        ErrorMissingParen   "RE2::ErrorMissingParen"       # missing closing )
        ErrorTrailingBackslash "RE2::ErrorTrailingBackslash"  # trailing \ at end of regexp
        ErrorRepeatArgument "RE2::ErrorRepeatArgument"     # repeat argument missing, e.g. "*"
        ErrorRepeatSize "RE2::ErrorRepeatSize"         # bad repetition argument
        ErrorRepeatOp "RE2::ErrorRepeatOp"           # bad repetition operator
        ErrorBadPerlOp "RE2::ErrorBadPerlOp"          # bad perl operator
        ErrorBadUTF8 "RE2::ErrorBadUTF8"            # invalid UTF-8 in regexp
        ErrorBadNamedCapture "RE2::ErrorBadNamedCapture"    # bad named capture group
        ErrorPatternTooLarge "RE2::ErrorPatternTooLarge"    # pattern too large (compile failed)
