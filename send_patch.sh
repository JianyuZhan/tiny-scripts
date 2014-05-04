#!/bin/bash

die() {
	echo "$@"
	exit 1
}

if [ $# != 1 ]; then
	die "Usage : ./`basename $0` <patch file>"
fi

top_dir=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z $top_dir ]; then
	die "Not in linux kernel git directory!"
fi

to=''
cc=''
while read line  
do
	tmp=$(echo $line | grep '<') # contains left angle bracket?
	if [ -n "$tmp" ]; then
		email=$(echo $line | sed -e 's/.*<\(.*\)>.*/\1/')
		to=${to}"--to "${email}" " 
	else
		email=$(echo $line | cut -d ' ' -f 1)
		cc=${cc}"--cc "${email}" "
	fi
done << EOF
$($top_dir/scripts/get_maintainer.pl $1)
EOF

# cc to myself too ;-)
cc=${cc}" --cc nasa4836@gmail.com"
cmd="git send-email "${to}${cc}" "$1
echo $cmd
exec $cmd
