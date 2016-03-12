#!/bin/bash

$START_COMMIT=$1
$END_COMMIT=$2

git format-patch -o ~/my_linux_patches/  -s --cover-letter -n --thread=shallow  ${START_COMMIT}^..${END_COMMIT}
