MKSHELL = rc

destdir = ''
prefix = /usr/local
bindir = $prefix/sbin
etcdir = $prefix/etc
libdir = $prefix/lib
mandir = $prefix/share/man/man1

root = /
pkgdb = `{cleanname $root/var/lib/spmk}
spmk_mk_d = $etcdir/spmk
pubkeydir = $etcdir/spmk/pubkeys
spmk_privkey = $etcdir/spmk/priv.key
tmpdir = `{cleanname $root/tmp/spmk}
spmk_inc = $libdir/spmk/inc

< config.mk

binfiles = spmk spmk_add spmk_rm
subrfiles = main vcs

install:V:
  mkdir -p $destdir/$bindir $destdir/$etcdir/spmk $destdir/$libdir/spmk
  mkdir -p $destdir/$pubkeydir $destdir/$mandir $destdir/$spmk_inc
  awk '/^(spmk_mk_d|pkgdb|root|spmk_inc|spmk_privkey)=/ {
         sub(/=.*$/, "")
         printf("%s=%s\n", $1, ENVIRON[$1])
         next
       }
       {print}' < spmk > $destdir/$bindir/spmk
  chmod 755 $destdir/$bindir/spmk
  for (f in spmk_add spmk_rm) {
    awk \
      '/^root=/ {printf("root=\"%s\"\n", ENVIRON["root"]); next}
       /^pkgdb=/ {printf("pkgdb=\"%s\"\n", ENVIRON["pkgdb"]); next}
       /^tmpdir=/ {printf("tmpdir=\"%s\"\n", ENVIRON["tmpdir"]); next}
       /^save=/ {printf("save=\"%s/spmk/save\"\n", ENVIRON["etcdir"]); next}
       /^pubkeydir=/ {printf("pubkeydir=\"%s\"\n", ENVIRON["pubkeydir"]); next}
       /^exclude=/ {
         printf("exclude=\"%s/spmk/exclude\"\n", ENVIRON["etcdir"])
         next
       }
       {print}' < $f > $destdir/$bindir/$f
      chmod 755 $destdir/$bindir/$f
  }
  touch $destdir/$spmk_mk_d/empty.mk
  cp $subrfiles $destdir/$spmk_inc
  cp spmk.1 $destdir/$mandir
