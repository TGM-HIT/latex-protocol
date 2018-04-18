#!/usr/bin/env python3

"""
============================
::  A latex build script  ::
============================

A multipurpose latex build script in python

@author     Markus Re1 <markus@re1.at>
@version    2018-04-17
@url        https://github.com/re1/tools


Copyright 2018 Markus Re1

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"""

import argparse
import re

from glob import glob
from os import getcwd, remove
from os.path import isfile
from shutil import rmtree
from subprocess import call

# color codes to style console output
R = "\033[0m"       # reset colors
CL = "\033[91m"     # light gray
CR = "\033[91m"     # red
CG = "\033[92m"     # green
CO = "\033[93m"     # orange
CB = "\033[94m"     # blue
CP = "\033[95m"     # purple
CC = "\033[96m"     # cyan
# temporary files to remove during cleanup
TMP = [["**/*.acn", "**/*.acr", "**/*.alg", "**/*.aux", "**/*.bbl", "**/*.blg", "**/*-blx.bib",
        "**/*.bcf", "**/*.dvi", "**/*.glg", "**/*.glo", "**/*.gls", "**/*.glsdefs", "**/*.ist",
        "**/*.out", "**/*.run.xml", "**/*.synctex.gz", "**/*.toc", "**/*.xdy", "**/*.lot",
        "**/*.lof", "**/*.lol"], []]


def bibtex(file="main", skip=False) -> bool:
    """
    Compile bibliography found in the given file using bibtex

    :param skip: always return True
    :param file: filename of a tex source file without its extension
    :return: True on success or False on error
    """
    print(CB + "Run " + CP + "bibtex" + R + " on " + CC + file + ".tex" + R)

    cmd = ("bibtex", file)      # compile command string before call
    res = call(tuple(cmd)) < 1  # call the command and watch for errors

    print(CG + "Success on " + CP + "bibtex" + R if res else CR + "Error on bibtex" + R)
    print()                     # empty line for better readability
    return skip or res          # return success or skip errors


def glossaries(file="main", out=".", skip=False) -> bool:
    """
    Compile glossary entries found in the given file using makeglossaries

    :param skip: always return true
    :param file: filename of a tex source file without its extension
    :param out: path to copy compiled glossaries into
    :return: True on success or False on error
    """
    print(CB + "Run " + CP + "makeglossaries" + R + " on " + CC + file + ".glo" + R)
    # compile command string before call
    cmd = ("makeglossaries", "-d", out, file)
    res = call(tuple(cmd)) < 1  # call the command and watch for errors

    print(CG + "Success on " + CP + "glossaries" + R if res else CR + "Error on glossaries" + R)
    print()                     # empty line for better readability
    return skip or res          # return success or skip errors


def tex(*args, command="pdflatex", file="main", verbose=False, out=".", skip=False) -> bool:
    """
    Compiles a tex source file using the given command

    :param skip: always return true
    :param args: additional arguments passed to the tex command
    :param command: tex command used to compile the source files
    :param file: filename of a tex source file without its extension
    :param verbose: show output of tex command interaction
    :param out: path to generate compiled files into
    :return: True on success or False on error
    """
    print(CB + "Run " + CP + command + R + " on " + CC + file + ".tex" + R)

    mode = "nonstopmode" if verbose else "batchmode"
    cmd = [command,                     # build the final command before calling it
           "-shell-escape",             # required by minted
           "-file-line-error",          # show tag beneath log lines
           "-interaction=" + mode,      # interaction mode
           "-output-directory=" + out,  # output directory
           *args, 						# additional arguments
           file.replace(".tex", "")] 	# file name without extension
    res = call(tuple(cmd)) < 1          # call the command and watch for errors

    if isfile(file + ".log"):           # list warnings and errors found in log file
        with open(file + ".log", "r", errors="replace") as log:
            for line in log:
                if re.search(":[0-9]*:", line):         # find errors
                    print(CR + "Error: " + line)
                if re.search("[0-9]+--[0-9]+", line):   # find warnings
                    print(CO + "Warning: " + R + line.replace("\n", ""))

    print(CG + "Success on " + CP + command + R if res else CR + "Error on " + command + R)
    print()                 # empty line for better readability
    return skip or res      # return success or skip errors


def clean(recursive=True) -> bool:
    """
    Clean up directory by removing any file listed in the TMP[0] constant
    and any directory listed in the TMP[1] constant

    :param recursive: also delete files from subdirectories when using **
    """
    print(CB + "Run " + CP + "clean" + R + " on " + CC + getcwd() + R)
    # delete temporary files
    res = [[remove(f) for f in glob(name, recursive=recursive)] for name in TMP[0]]
    # delete temporary directories
    res += [[rmtree(f) for f in glob(name, recursive=recursive)] for name in TMP[1]]
    # return success or rare case of error
    return all(res)


def full(*args, command="pdflatex", file="main", verbose=False, out=".", skip=False) -> bool:
    """
    Attempt a full compilation process and compile glossary entries such as bibliography if found

    :param skip: always return true
    :param args: additional arguments passed to the tex command
    :param command: tex command used to compile the source files
    :param file: filename of a tex source file without its extension
    :param verbose: show output of tex command interaction
    :param out: path to generate compiled files into
    :return: True on success or False on error
    """
    if not (tex(*args, command=command, file=file, verbose=verbose, out=out) or skip):
        return False            # return error
    if glob("*.bib"):  # bib files can have different names than the main file
        bibtex(file=file)       # compile bibliography and call progressive tex commands
        if not (tex(*args, command=command, file=file, verbose=verbose, out=out) or skip):
            return False        # return error
        if not (tex(*args, command=command, file=file, verbose=verbose, out=out) or skip):
            return False        # return error
    if isfile(file + ".glo"):   # compile glossary entries using and call a progressive tex command
        if not (glossaries(file=file, out=out) or skip):
            return False        # return error
        if not (tex(*args, command=command, file=file, verbose=verbose, out=out) or skip):
            return False        # return error
    clean()                     # clean up after compilation
    return True                 # return success


def parse(args):
    """
    Parse arguments from the args list and act according to their values

    :param args: list of arguments to parse
    """
    # additional arguments for a targets command
    arguments = args.args.split(" ") if args.args else []
    # tex command to use when compiling tex sources
    command = "pdflatex"
    # names of the tex source files to compile without their extension
    files = args.files if isinstance(args.files, list) else [args.files]
    out = args.out or "."           # directory to copy generated files into
    skip = args.skip                # remember to ignore errors
    target = args.target or "full"  # choose target full by default
    verbose = args.verbose          # interaction mode for tex commands
    # change tex command according to the arguments given by the user
    if args.latex:
        command = "latex"
    if args.xelatex:
        command = "xelatex"
    # spare temp files
    if not args.log:        # add log files and to temp file list
        TMP[0].append("**/*.log")
    if not args.minted:     # add minted dir to temp dir list
        TMP[1].append("**/*_minted-*")
    res = []					# assume success
    # choose a target or fall back to full compilation
    if "clean" in target:       # clean up files and directories listed in the TMP constant
        clean()
    elif "draft" in target:     # run the tex command once
        res = [tex(*arguments, command=command, file=file, verbose=verbose, out=out, skip=skip) for file in files]
    elif "glo" in target:       # compile glossary entries
        res = [glossaries(file=file, out=out, skip=skip) for file in files]
    elif "bib" in target:       # compile bibliography entries using bibtex
        res = [bibtex(file=file, skip=skip) for file in files]
    else:                       # attempt a full compilation by default
        res = [full(*arguments, command=command, file=file, verbose=verbose, out=out, skip=skip) for file in files]
    # log success
    print(CG + "Success on " + CP + target + R if all(res) else CR + "Error on " + target + R)


if __name__ == "__main__":
    # create an argument parser instance and add various options
    PARSER = argparse.ArgumentParser(
        description="This python script helps compiling latex documents "
                    "by providing most functions you would except from a build tool.")
    # add arguments for different use-cases
    PARSER.add_argument("target", nargs="?", default="full",
                        help="the script will attempt a full compilation process by default ."
                             " To specify the target manually append bib, clean, draft or glo.")
    PARSER.add_argument("-f", "--files", nargs="*", default="main", help="source tex files to compile")
    PARSER.add_argument("-l", "--log", action="store_true", help="spare log during cleanup")
    PARSER.add_argument("-m", "--minted", action="store_true", help="spare minted during cleanup")
    PARSER.add_argument("-q", "--quiet", action="store_true", help="only show fatal errors")
    PARSER.add_argument("-s", "--skip", action="store_true", help="skip errors in tex commands")
    PARSER.add_argument("-v", "--verbose", action="store_true", help="do not filter logs")
    PARSER.add_argument("-a", "--args", help="additional arguments for the operation")
    PARSER.add_argument("-o", "--out", help="output directory to use if supported by the operation")
    # only allow a single compiler
    COMPILERS = PARSER.add_argument_group("latex compilers").add_mutually_exclusive_group()
    COMPILERS.add_argument("-t", "--latex", action="store_true", help="parse tex files with latex")
    COMPILERS.add_argument("-x", "--xelatex", action="store_true",
                           help="compile tex files using xelatex (helps loading custom fonts")
    # parse arguments
    parse(PARSER.parse_args())
