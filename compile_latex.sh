#!/bin/bash

xelatex "$1"
bibtex ${1%.tex}.aux
xelatex "$1"
xelatex "$1"
