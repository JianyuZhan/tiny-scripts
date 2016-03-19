#!/bin/bash

die() {
        echo "$@"
        exit 1
}

if [ $# == 0 ]; then
        die "Usage : ./`basename $0` <patch file or patches directory>"
fi

MSMTP_BIN=`which msmtp`

top_dir=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z $top_dir ]; then
        die "Not in linux kernel git directory!"
fi

TO_LIST=''
CC_LIST=''

git_blame_one() {
    local patch=$1
    local tmp
    local email

    echo "Parsing patch: ${patch##/}..."

    while read line  
    do
        tmp=$(echo $line | grep '<') # contains left angle bracket?
        if [ -n "$tmp" ]; then
            email=$(echo $line | sed -e 's/.*<\(.*\)>.*/\1/')
            if [[ "${TO_LIST}" != *"${email}"* ]]; then
                TO_LIST=${TO_LIST}"--to "${email}" " 
	    fi
        else
            email=$(echo $line | cut -d ' ' -f 1)
            if [[ "${CC_LIST}" != *"${email}"* ]]; then
                CC_LIST=${CC_LIST}"--cc "${email}" "
	    fi
        fi  
    done << EOF
$($top_dir/scripts/get_maintainer.pl --git-blame ${patch} 2>/dev/null)
EOF
}

if [ -f "$1" ]; then
	git_blame_one "$1"
elif [ -d "$1" ]; then
	for p in `ls ${1%/}/*patch 2>/dev/null`; do
		git_blame_one "$p"
	done
fi

cmd="git send-email --smtp-server "${MSMTP_BIN}" --quiet "${TO_LIST}${CC_LIST}" "$1

echo
echo $cmd
echo

read -s -n 1 -p "Want to send using above command? [Y/N]" answer
if [ "$answer" == "Y" -o "$answer" == "y" ]; then
    exec $cmd
fi
echo
