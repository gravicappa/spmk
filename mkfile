prefix = /usr/local
bindir = $prefix/sbin
etcdir = $prefix/etc
cmddir = $prefix/lib/spkg
mandir = $prefix/share/man/man1

root = /
pkgdb = `{cleanname $root/var/lib/spkg}
spkg_mk = $etcdir/spkg.mk
pubkey = $etcdir/key.pub
tmpdir = `{cleanname $root/tmp/spkg}
spkg_header = $cmddir/spkg_header.rc

binfiles = spkg spkg_add spkg_rm 
cmdfiles = mkpkg mkports mkrevdep mkdep 

install:V:
	mkdir -p "$destdir/$bindir" "$destdir/$etcdir" "$destdir/$cmddir"
	mkdir -p "$destdir/$mandir"
	awk '/^cmddir=/ {printf("cmddir=%s\n", ENVIRON["cmddir"]); next;}
			 /^spkg_header=/ {
			   printf("spkg_header=%s\n", ENVIRON["spkg_header"]);
				 next;
			 }
		   /^spkg_mk=/ {printf("spkg_mk=%s\n", ENVIRON["spkg_mk"]); next;}
		   /^pkgdb=/ {printf("pkgdb=%s\n", ENVIRON["pkgdb"]); next;}
		   /^root=/ {printf("root=%s\n", ENVIRON["root"]); next;}
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
		cp "$f" "$destdir/$cmddir"
		chmod 755 "$f"
	done
  
	cp spkg.mk "$destdir/$etcdir"
	cp spkg_header.rc "$destdir/$cmddir"
	cp spkg.1 "$destdir/$mandir"
