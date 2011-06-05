prefix = /usr/local
bindir = $prefix/sbin
etcdir = $prefix/etc
cmddir = $prefix/lib
mandir = $prefix/share/man/man1

root = /
pkgdb = `{cleanname $root/var/lib/spmk}
spmk_mk = $etcdir/spmk/local.mk
pubkey = $etcdir/spmk/pub.key
spmk_privkey = $etcdir/spmk/priv.key
tmpdir = `{cleanname $root/tmp/spmk}
spmk_header = $cmddir/spmk/header.subr

binfiles = spmk spmk_add spmk_rm
cmdfiles = mkpkg mkports mkrevdep mkdep
subrfiles = header.subr

install:V:
  mkdir -p "$destdir/$bindir" "$destdir/$etcdir/spmk" "$destdir/$cmddir/spmk"
  mkdir -p "$destdir/$mandir"
  awk '/^(spmk_mk|pkgdb|root|spmk_header|spmk_privkey)=/ {
         sub(/=.*$/, "");
         printf("%s=%s\n", $1, ENVIRON[$1]);
         next;
       }
       /^spmk_cmddir=/ {
         printf("spmk_cmddir=%s/spmk\n", ENVIRON["cmddir"]);
         next;
       }
       {print;}' < spmk > $destdir/$bindir/spmk
  chmod 755 "$destdir/$bindir/spmk"
  for f in spmk_add spmk_rm ; do
    awk \
      '/^root=/ {printf("root=\"%s\"\n", ENVIRON["root"]); next;}
       /^pkgdb=/ {printf("pkgdb=\"%s\"\n", ENVIRON["pkgdb"]); next;}
       /^tmpdir=/ {printf("tmpdir=\"%s\"\n", ENVIRON["tmpdir"]); next;}
       /^pubkey=/ {printf("pubkey=\"%s\"\n", ENVIRON["pubkey"]); next;}
       {print}' < "$f" > "$destdir/$bindir/$f"
      chmod 755 "$destdir/$bindir/$f"
  done
  for f in $cmdfiles ; do
    cp "$f" "$destdir/$cmddir/spmk/"
    chmod 755 "$destdir/$cmddir/spmk/$f"
  done
  cp $subrfiles "$destdir/$cmddir/spmk/"
  cp spmk.mk "$destdir/$spmk_mk"
  cp spmk.1 "$destdir/$mandir"
