if [ $1 = '--post' ]; then
	cat $2 | ./markdown.awk
fi
