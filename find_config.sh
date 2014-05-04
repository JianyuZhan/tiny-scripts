#!/bin/bash

find . -type f -name Kconfig -exec grep -lw $1 {} \;
