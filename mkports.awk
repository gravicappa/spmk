#!/bin/awk -f

BEGIN {print "MKSHELL=rc"}
/^[^ \t].*:/ {
	rule = 1
	started = 0
	print
	next
}
$1 == start_pkg && rule {
	#print "  . $header"
	started = 1
}
$1 == end_pkg && started {
	print $0
	started = 0
}
{print}
END {print "< $spkgdir/spkg.mk"}