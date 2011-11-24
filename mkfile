MKSHELL = rc

destdir = ''
prefix = /usr/local
bindir = $prefix/sbin
etcdir = $prefix/etc
cmddir = $prefix/lib
mandir = $prefix/share/man/man1

root = /
pkgdb = `{cleanname $root/var/lib/spmk}
spmk_mk_d = $etcdir/spmk
pubkey = $etcdir/spmk/pub.key
spmk_privkey = $etcdir/spmk/priv.key
tmpdir = `{cleanname $root/tmp/spmk}
spmk_header = $cmddir/spmk/header.subr

binfiles = spmk spmk_add spmk_rm
cmdfiles = mkpkg mkports.awk mkrevdep mkdep.awk
subrfiles = header.subr

install:V:
  mkdir -p $destdir/$bindir $destdir/$etcdir/spmk $destdir/$cmddir/spmk
  mkdir -p $destdir/$mandir
  awk '/^(spmk_mk_d|pkgdb|root|spmk_header|spmk_privkey)=/ {
         sub(/=.*$/, "");
         printf("%s=%s\n", $1, ENVIRON[$1]);
         next;
       }
       /^spmk_cmddir=/ {
         printf("spmk_cmddir=%s/spmk\n", ENVIRON["cmddir"]);
         next;
       }
       {print;}' < spmk > $destdir/$bindir/spmk
  chmod 755 $destdir/$bindir/spmk
  for (f in spmk_add spmk_rm) {
    awk \
      '/^root=/ {printf("root=\"%s\"\n", ENVIRON["root"]); next}
       /^pkgdb=/ {printf("pkgdb=\"%s\"\n", ENVIRON["pkgdb"]); next}
       /^tmpdir=/ {printf("tmpdir=\"%s\"\n", ENVIRON["tmpdir"]); next}
       /^pubkey=/ {printf("pubkey=\"%s\"\n", ENVIRON["pubkey"]); next}
       /^save=/ {printf("save=\"%s/spmk/save\"\n", ENVIRON["etcdir"]);next}
       /^exclude=/ {
         printf("exclude=\"%s/spmk/exclude\"\n", ENVIRON["etcdir"])
         next
       }
       {print}' < $f > $destdir/$bindir/$f
      chmod 755 $destdir/$bindir/$f
  }
  for (f in $cmdfiles) {
    cp $f $destdir/$cmddir/spmk/
    chmod 755 $destdir/$cmddir/spmk/$f
  }
  touch $destdir/$spmk_mk_d/empty.mk
  cp $subrfiles $destdir/$cmddir/spmk/
  cp spmk.1 $destdir/$mandir
