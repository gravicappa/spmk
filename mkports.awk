BEGIN {print "MKSHELL=rc"}

/^[ \t]*\.[ \t]*\$spmk_header/ {
	f = FILENAME;
	sub(/\/[^\/]*$/, "", f);
	print "  portdir='" f "'";
}

{print}

END {print "<|cat $spmk_mk_d/*.mk"}
