prefix = /usr/local
bindir = $prefix/sbin
etcdir = $prefix/etc
cmddir = $prefix/lib
mandir = $prefix/share/man/man1

root = /
pkgdb = `{cleanname $root/var/lib/spkg}
spkg_mk = $etcdir/spkg/local.mk
pubkey = $etcdir/spkg/pub.key
spkg_privkey = $etcdir/spkg/priv.key
tmpdir = `{cleanname $root/tmp/spkg}
spkg_header = $cmddir/spkg/spkg_header.rc

binfiles = spkg spkg_add spkg_rm 
cmdfiles = mkpkg mkports mkrevdep mkdep 

install:V:
	mkdir -p "$destdir/$bindir" "$destdir/$etcdir/spkg" "$destdir/$cmddir/spkg"
	mkdir -p "$destdir/$mandir"
	awk '/^(cmddir|spkg_mk|pkgdb|root|spkg_header|spkg_privkey)=/ {
			   sub(/=.*$/, "");
				 printf("%s=%s\n", $1, ENVIRON[$1]);
				 next
			 }
			 {print;}' < spkg > $destdir/$bindir/spkg
	chmod 755 "$destdir/$bindir/spkg"
	for f in spkg_add spkg_rm ; do
		awk \
		  '/^root=/ {printf("root=\"%s\"\n", ENVIRON["root"]); next;}
		   /^pkgdb=/ {printf("pkgdb=\"%s\"\n", ENVIRON["pkgdb"]); next;}
		   /^tmpdir=/ {printf("tmpdir=\"%s\"\n", ENVIRON["tmpdir"]); next;}
			 /^pubkey=/ {printf("pubkey=\"%s\"\n", ENVIRON["pubkey"]); next;}
			 {print}' < "$f" > "$destdir/$bindir/$f"
			chmod 755 "$destdir/$bindir/$f"
	done
	for f in $cmdfiles ; do
		cp "$f" "$destdir/$cmddir/spkg"
		chmod 755 "$f"
	done
	cp spkg.mk "$destdir/$spkg_mk"
	cp spkg_header.rc "$destdir/$spkg_header"
	cp spkg.1 "$destdir/$mandir"
