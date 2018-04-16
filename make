#!/usr/bin/env python3

"""
==========================
||  LaTeX build script  ||
==========================

Helps building LaTeX documents on multiple platforms.

@author     Markus Re1 <markus@re1.at>
@version    2018-04-17
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
        "**/*.lof", "**/*.lol"], ["**/*_minted-*"]]


def bibtex(file="main", skip=False) -> bool:
    """
    Compile bibliography found in the given file using bibtex

    :param skip: always return True
    :param file: filename of a tex source file without its extension
    :return: True on success or False on error
    """
    print(CB + "Run " + CP + "bibtex" + R + " on " + CC + file + ".tex" + R)

    cmd = ("bibtex", file)          # compile command string before call
    success = call(tuple(cmd)) < 1  # call the command and watch for errors

    print(CG + "Success on " + CP + "bibtex" + R if success else CR + "Error on bibtex" + R)
    print()                         # empty line for better readability
    return skip or success          # return success or skip errors


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
    success = call(tuple(cmd)) < 1  # call the command and watch for errors

    print(CG + "Success on " + CP + "glossaries" + R if success else CR + "Error on glossaries" + R)
    print()                         # empty line for better readability
    return skip or success          # return success or skip errors


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
    print(CB + "Run " + CP + command + R + "on " + CC + file + ".tex" + R)

    mode = "nonstopmode" if verbose else "batchmode"
    cmd = [command,                     # build the final command before calling it
           "-shell-escape",             # required by minted
           "-file-line-error",          # show tag beneath log lines
           "-interaction=" + mode,      # interaction mode
           "-output-directory=" + out,  # output directory
           *args, file]                 # additional args and filename
    success = call(tuple(cmd)) < 1      # call the command and watch for errors

    if isfile(file + ".log"):           # list warnings and errors found in log file
        with open(file + ".log", "r", errors="replace") as log:
            for line in log:
                if re.search(":[0-9]*:", line):         # find errors
                    print(CR + "Error: " + line)
                if re.search("[0-9]+--[0-9]+", line):   # find warnings
                    print(CO + "Warning: " + R + line.replace("\n", ""))

    print(CG + "Success on " + CP + command + R if success else CR + "Error on " + command + R)
    print()                 # empty line for better readability
    return skip or success  # return success or skip errors


def clean(recursive=True):
    """
    Clean up directory by removing any file listed in the TMP[0] constant
    and any directory listed in the TMP[1] constant

    :param recursive: also delete files from subdirectories when using **
    """
    print(CB + "Run " + CP + "clean" + R + " on " + CC + getcwd() + R)
    # delete temporary files
    any([remove(f) for f in glob(name, recursive=recursive)] for name in TMP[0])
    # delete temporary directories
    any([rmtree(f) for f in glob(name, recursive=recursive)] for name in TMP[1])


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
    files = args.files.replace(".tex", "").split(" ")
    skip = args.skip                # remember to ignore errors
    verbose = args.verbose          # interaction mode for tex commands
    out = args.out or "."           # directory to copy generated files into
    # change tex command according to the arguments given by the user
    if args.latex:
        command = "latex"
    if args.xelatex:
        command = "xelatex"
    # add log files to temporary file list if no argument is given
    if not args.log:
        TMP[0].append("**/*.log")
    # decide on a target
    if "clean" in args.target:      # clean up files and directories listed in the TMP constant
        clean()
    elif "draft" in args.target:    # run the tex command once
        for file in files:          # iterate over source files
            tex(*arguments, command=command, file=file, verbose=verbose, out=out, skip=skip)
    elif "glo" in args.target:      # compile glossary entries
        for file in files:          # iterate over source files
            glossaries(file=file, out=out, skip=skip)
    elif "bib" in args.target:      # compile bibliography entries using bibtex
        for file in files:          # iterate over source files
            bibtex(file=file, skip=skip)
    else:                           # attempt a full compilation by default
        for file in files:          # iterate over source files
            full(*arguments, command=command, file=file, verbose=verbose, out=out, skip=skip)


if __name__ == "__main__":
    # create an argument parser instance and add various options
    PARSER = argparse.ArgumentParser(
        description="This python script helps compiling latex documents "
                    "by providing most functions you would except from a build tool.")
    # add arguments for different use-cases
    PARSER.add_argument("target", nargs="?", default="all",
                        help="the script will attempt a full compilation process by default ."
                             " To specify the target manually append bib, clean, draft or glo.")
    PARSER.add_argument("files", nargs="*", default="main", help="source tex files to compile")
    PARSER.add_argument("-l", "--log", action="store_true", help="spare log files during cleanup")
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
