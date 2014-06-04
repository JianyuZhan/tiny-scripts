#!/bin/bash

die() {
	echo -e "$@"
	exit 42
}

if [ $# != 1 ]; then
	die "Usage : ./`basename $0` <company name or its domain name>. E.g.\n\
	\t./`basename $0` \"unitedstack.com\""
fi

top_dir=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z $top_dir ]; then
	die "Not in a git directory!"
fi

echo -e "\nAnalysing commit history...\n"

now=$(date +%Y-%m)
now_year=$(date +%Y)
now_month=$(date +%-m)

if ((now_month - 12 < 0)); then
	start_year=$((now_year-1))
	start_month=$((now_month+1))
else
	start_year=$((now_year))
	start_month=$((now_month-11))
fi
start_ym=$start_year-$([ $start_month -lt 10 ] && echo 0$start_month || echo $start_month)

git log --author="$1" --date="short" > /tmp/commit_history
total_commits=$(cat /tmp/commit_history | grep -E "^Date" | wc -l)
first_commit=$(cat /tmp/commit_history | grep -E "^Date" | sed -e 's/.*\([0-9]\{4\}\-[0-9]\{2\}\-[0-9]\{2\}\).*/\1/' | tail -n1)
first_commit_id=$(cat /tmp/commit_history | grep -E "^commit" | cut -d ' ' -f 2 | tail -n1)

last_commit=$(cat /tmp/commit_history | grep -E "^Date" | sed -e 's/.*\([0-9]\{4\}\-[0-9]\{2\}\-[0-9]\{2\}\).*/\1/' | head -n1)
last_commit_id=$(cat /tmp/commit_history | grep -E "^commit" | cut -d ' ' -f 2 | head -n1)

:> /tmp/ym_list
while read line  
do
	tmp_ym=$(echo $line | cut -d ' ' -f 2)
	if [[ "$tmp_ym" < "$start_ym" ]]; then
		continue;
	else
		echo $line >> /tmp/ym_list
	fi
done << EOF
$(cat /tmp/commit_history | grep -E "^Date" | sed -e 's/.*\([0-9]\{4\}\-[0-9]\{2\}\).*/\1/' | sort | uniq -c)
EOF

echo "Total commits:   "$total_commits
if [ ! "$total_commits" -eq 0 ]; then
	echo "First commit at: "$first_commit"(SHA1: "$first_commit_id")"
	echo "Last  commit at: "$last_commit"(SHA1: "$last_commit_id")"
fi

if [ -s /tmp/commit_history ]; then
	echo -e "\nCommit activity in last 12 months:"
	
	most_commit_nr=$(cat /tmp/ym_list | sort -n -k1 | tail -n1 | cut -d ' ' -f 1)
	width=${#most_commit_nr}
	let "dash_per_commit = ($most_commit_nr + 70 - 1) / 70"

	while read line
	do
		nr=$(echo $line | cut -d ' ' -f 1)
		nr_width=${#nr}
		date=$(echo $line | cut -d ' ' -f 2)
		output=$date" | "
		while [ $nr_width -lt $width ]; do
			output+="\x20" # whitespace
			let "nr_width+=1"
		done
		output+=$nr" "

		let "nr_dash = ($nr + $dash_per_commit - 1) / $dash_per_commit"
		while [ $nr_dash -gt 0 ]; do
			output+="-"
			let "nr_dash -= 1"
		done
		echo -e $output
	done < /tmp/ym_list
fi
