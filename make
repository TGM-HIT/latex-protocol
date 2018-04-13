#!/usr/bin/env python

"""
==========================
||  LaTeX build script  ||
==========================
Helps building LaTeX documents on multiple platforms

@author     Markus Re1 <markus@re1.at>
@version    2018-04-13
"""

import argparse
import sys

from glob import glob
from os import getcwd, listdir, remove
from os.path import expanduser, join, isdir
from shutil import copyfile, rmtree
from subprocess import call

# Color codes to style console output
R = "\033[0m"      # reset colors
CL = "\033[91m"    # light gray
CR = "\033[91m"    # red
CG = "\033[92m"    # green
CO = "\033[93m"    # orange
CB = "\033[94m"    # blue
CP = "\033[95m"    # purple
CC = "\033[96m"    # cyan
# Temporary files used for cleanup
TMP = [[
    "**/*.acn", "**/*.acr", "**/*.alg", "**/*.aux", "**/*.bbl", "**/*.blg", "**/*-blx.bib", "**/*.bcf", "**/*.dvi",
    "**/*.glg", "**/*.glo", "**/*.gls", "**/*.glsdefs", "**/*.ist", "**/*.out", "**/*.run.xml", "**/*.synctex.gz",
    "**/*.toc", "**/*.xdy", "**/*.lot", "**/*.lof", "**/*.lol"], [
    "**/*_minted-*"]]


def glossaries(file="main", out="."):
    print(CB + "Run " + CP + "makeglossaries" + R + "on " + CC + file + ".glo" + R)
    cmd = ("makeglossaries", "-d", out, file)
    if call(tuple(cmd)) < 1:
        print(CG + "Everything okay with" + CP + "makeglossaries" + R + "!")
    else:
        print(CR + "Process finished with errors!" + R)


def tex(*args, command="pdflatex", file="main", mode="batchmode", out="."):
    print(CB + "Run " + CP + command + R + "on " + CC + file + ".tex" + R)
    cmd = [command,
           "-shell-escape",        # required by minted
           "-file-line-error",     # show tag beneath log lines
           "-interaction=%s" % mode,
           "-output-directory=%s" % out,
           *args, file]

    if call(tuple(cmd)) < 1:
        print(CG + "Everything okay!" + R)
    else:
        print(CR + "Process finished with errors!" + R)


def clean(recursive=True):
    print(CB + "Run " + CP + "clean" + R + " on " + CC + getcwd() + R)
    # Delete temporary files
    [[remove(f) for f in glob(name, recursive=recursive)] for name in TMP[0]]
    # Delete temporary directories
    [[rmtree(f) for f in glob(name, recursive=recursive)] for name in TMP[1]]


def parse(args):
    command = "pdflatex"
    file = args.file.replace(".tex", "") if args.file else "main"
    mode = "nonstopmode" if args.verbose else "batchmode"
    out = args.out or "."
    arguments = args.args.split(" ") if args.args else []

    if not args.log:
        TMP[0].append("**/*.log")

    if args.latex:
        command = "latex"
    if args.pdf:
        command = "pdflatex"
    if args.xelatex:
        command = "xelatex"

    tex(*arguments, command=command, file=file, mode=mode, out=out)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="This python script helps compiling latex documents "
                    "by providing most functions you would except from a build tool.")

    parser.add_argument("-l", "--log", help="spare log files during cleanup", action="store_true")
    parser.add_argument("-q", "--quiet", help="only show fatal errors", action="store_true")
    parser.add_argument("-v", "--verbose", help="enable extended logging for commands", action="store_true")
    parser.add_argument("-a", "--args", help="additional arguments for the operation")
    parser.add_argument("-f", "--file", help="source tex file to use an operation on")
    parser.add_argument("-o", "--out", help="output directory to use if supported by the operation")

    compilers = parser.add_argument_group("latex compilers").add_mutually_exclusive_group()
    compilers.add_argument("-t", "--latex", help="use latex to parse tex files", action="store_true")
    compilers.add_argument("-x", "--xelatex", help="use xelatex to compile pdfs from tex sources", action="store_true")
    compilers.add_argument("-p", "--pdf", help="use pdflatex to produce pdfs from tex sources", action="store_true")

    parse(parser.parse_args())
    clean()
