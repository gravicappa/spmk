#!/bin/awk -f
BEGIN {print "MKSHELL=rc"}

/^[^ \t].*:/ {
	sub(/:.*:/, ":VQ:")
	rule = 1
	print
}

/^[ \t]/ && rule {
	print "  echo $target"
	print ""
	rule = 0
	next
}
