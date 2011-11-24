BEGIN {print "MKSHELL=rc"}

/^[^ \t].*:/ {
	sub(/:.*:/, ":VQ:")
	rule = 1
	print
}

/^[ \t]/ && rule {
	printf("  echo $target\n\n")
	rule = 0
	next
}
