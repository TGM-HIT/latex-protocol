#!/usr/bin/env python

"""
==========================
||  LaTeX build script  ||
==========================
Helps building LaTeX documents on multiple platforms.

@author     Markus Re1 <markus@re1.at>
@version    2018-04-13
"""

import argparse
import re
import sys

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
TMP = [["**/*.acn", "**/*.acr", "**/*.alg", "**/*.aux", "**/*.bbl", "**/*.blg", "**/*-blx.bib", "**/*.bcf", "**/*.dvi",
        "**/*.glg", "**/*.glo", "**/*.gls", "**/*.glsdefs", "**/*.ist", "**/*.out", "**/*.run.xml", "**/*.synctex.gz",
        "**/*.toc", "**/*.xdy", "**/*.lot", "**/*.lof", "**/*.lol"], ["**/*_minted-*"]]


def bibtex(file="main"):
    """
    Compile bibliography found in the given file using bibtex
    :param file: filename of a tex source file without its extension
    """
    cmd = ("bibtex", file)      # compile command string before call
    if call(tuple(cmd)) < 1:    # command exits without error code
        print(CG + "Everything okay with " + CP + "bibtex" + R)
    else:                       # command exits with error code
        print(CR + "Bibtex finished with errors" + R)


def glossaries(file="main", out="."):
    """
    Compile glossary entries found in the given file using makeglossaries
    :param file: filename of a tex source file without its extension
    :param out: path to copy compiled glossaries into
    """
    print(CB + "Run " + CP + "makeglossaries" + R + " on " + CC + file + ".glo" + R)
    # compile command string before call
    cmd = ("makeglossaries", "-d", out, file)
    if call(tuple(cmd)) < 1:    # command exits without error code
        print(CG + "Everything okay with " + CP + "makeglossaries" + R)
    else:                       # command exits with error code
        print(CR + "Makeglossaries finished with errors" + R)


def tex(*args, command="pdflatex", file="main", interaction="batchmode", out="."):
    """
    Compiles a tex source file using the given command
    :param args: additional arguments passed to the tex command
    :param command: tex command used to compile the source files
    :param file: filename of a tex source file without its extension
    :param interaction: interaction mode for the tex command
    :param out: path to generate compiled files into
    """
    print(CB + "Run " + CP + command + R + "on " + CC + file + ".tex" + R)
    cmd = [command,             # compile command string before call
           "-shell-escape",     # required by minted
           "-file-line-error",  # show tag beneath log lines
           "-interaction=%s" % interaction,
           "-output-directory=%s" % out,
           *args, file]
    # call the command and look out for errors
    if call(tuple(cmd)) < 1:    # command exits without error code
        print(CG + "Everything okay with " + CP + command + R)
    else:                       # command exits with error code
        print(CR + command + " finished with errors" + R)

    if isfile(file + ".log"):   # list warnings and errors found in log file
        with open(file + ".log", "r", errors="replace") as file:
            for line in file:
                if re.search(".*:[0-9]*:.*", line):     # find errors
                    print(CR + "Error: " + line)
                if re.search("[0-9]+--[0-9]+", line):   # find warnings
                    print(CO + "Warning: " + R + line)


def clean(recursive=True):
    """
    Clean up directory by removing any file listed in the TMP[0] constant
    and any directory listed in the TMP[1] constant
    :param recursive: also delete files from subdirectories when using **
    """
    print(CB + "Run " + CP + "clean" + R + " on " + CC + getcwd() + R)
    # delete temporary files
    [[remove(f) for f in glob(name, recursive=recursive)] for name in TMP[0]]
    # delete temporary directories
    [[rmtree(f) for f in glob(name, recursive=recursive)] for name in TMP[1]]


def full(*args, command="pdflatex", file="main", interaction="batchmode", out="."):
    """
    Attempt a full compilation process for the given file and compile glossary entries such as bibliography if found
    :param args: additional arguments passed to the tex command
    :param command: tex command used to compile the source files
    :param file: filename of a tex source file without its extension
    :param interaction: interaction mode for the tex command
    :param out: path to generate compiled files into
    """
    tex(*args, command=command, file=file, interaction=interaction, out=out)
    if len(glob("*.bib")) > 0:  # bib files can have different names than the main file
        bibtex(file=file)       # compile bibliography using bibtex and call progressive tex commands
        tex(*args, command=command, file=file, interaction=interaction, out=out)
        tex(*args, command=command, file=file, interaction=interaction, out=out)
    if isfile(file + ".glo"):   # compile glossary entries using and call a progressive tex command
        glossaries(file=file, out=out)
        tex(*args, command=command, file=file, interaction=interaction, out=out)
    clean()                     # clean up after compilation


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
    files = args.files.split(" ")
    # interaction mode for tex commands
    interaction = "nonstopmode" if args.verbose else "batchmode"
    # directory to copy generated files into
    out = args.out or "."
    # change tex command according to the arguments given by the user
    if args.latex:
        command = "latex"
    if args.pdf:
        command = "pdflatex"
    if args.xelatex:
        command = "xelatex"
    # add log files to temporary file list if no argument is given
    if not args.log:
        TMP[0].append("**/*.log")
    # decide on a target
    if "clean" in args.target:          # clean up files and directories listed in the TMP constant
        clean()
    elif "draft" in args.target:        # run the tex command once
        [tex(*arguments, command=command, file=file, interaction=interaction, out=out) for file in files]
    elif "glossaries" in args.target:   # compile glossary entries
        [glossaries(file=file, out=out) for file in files]
    elif "bibtex" in args.target:       # compile bibliography entries using bibtex
        [glossaries(file=file, out=out) for file in files]
    else:                               # attempt a full compilation by default
        [full(*arguments, command=command, file=file, interaction=interaction, out=out) for file in files]


if __name__ == "__main__":
    # create an argument parser instance and add various options
    parser = argparse.ArgumentParser(
        description="This python script helps compiling latex documents "
                    "by providing most functions you would except from a build tool.")
    # add arguments for different use-cases
    parser.add_argument("target", nargs="?", default="all",
                        help="the operation to use is picked by observing the given files and parameters."
                             " To set one by hand simply append a target from [clean, draft].")
    parser.add_argument("files", nargs="*", default="main", help="source tex files to compile")
    parser.add_argument("-l", "--log", action="store_true", help="spare log files during cleanup")
    parser.add_argument("-q", "--quiet", action="store_true", help="only show fatal errors")
    parser.add_argument("-v", "--verbose", action="store_true", help="enable extended logging for commands")
    parser.add_argument("-a", "--args", help="additional arguments for the operation")
    parser.add_argument("-o", "--out", help="output directory to use if supported by the operation")
    # only allow a single compiler
    compilers = parser.add_argument_group("latex compilers").add_mutually_exclusive_group()
    compilers.add_argument("-t", "--latex", action="store_true", help="use latex to parse tex files")
    compilers.add_argument("-x", "--xelatex", action="store_true", help="use xelatex to compile pdfs from tex sources")
    compilers.add_argument("-p", "--pdf", action="store_true", help="use pdflatex to produce pdfs from tex sources")
    # parse arguments
    parse(parser.parse_args())
