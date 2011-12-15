BEGIN {print "MKSHELL=rc"}

/^[^ \t].*:/ {
	sub(/:[A-Z]+:/, ":")
	sub(/:/, ":VQ:")
	rule = 1
	print
	next
}

/^[ \t]/ && rule {
	printf("  echo $target\n\n")
	rule = 0
	next
}

/^[^ \t]/ {print}
