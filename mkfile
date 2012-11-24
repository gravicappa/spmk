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
spmk_inc = $libdir/spmk

<config.mk

subrfiles = vcs

all:V: install

install_dirs:V:
  mkdir -p $destdir/$bindir $destdir/$etcdir/spmk $destdir/$libdir/spmk
  mkdir -p $destdir/$pubkeydir $destdir/$mandir $destdir/$spmk_inc

install_sp_sh:V:
  awk -F'=' '
    /^root=/ {
      printf("%s=\"${SPMK_ROOT:-%s}\"\n", $1, ENVIRON[$1])
      next
    }
    /^pkgdb=/ {
      printf("%s=\"${SPMK_DB:-%s}\"\n", $1, ENVIRON[$1])
      next
    }
    /^(tmpdir|pubkeydir|spmk_privkey)=/ {
      s = sprintf("%s=\"%s\"", $1, ENVIRON[$1])
      gsub(/\/\/*/, "/", s)
      print s
      next
    }
    /^save=/ {
      s = sprintf("save=\"%s/spmk/save\"", ENVIRON["etcdir"])
      gsub(/\/\/*/, "/", s)
      print s
      next
    }
    /^exclude=/ {
      s = sprintf("exclude=\"%s/spmk/exclude\"", ENVIRON["etcdir"])
      gsub(/\/\/*/, "/", s)
      print s
      next
    }
    {print}' <sp >$destdir/$bindir/sp


install:V: install_dirs install_sp_sh
  awk -F'=' '/^(spmk_mk_d|pkgdb|root|spmk_inc|spmk_privkey)=/ {
               printf("%s=''%s''\n", $1, ENVIRON[$1])
               next
             }
             {print}' <spmk >$destdir/$bindir/spmk
  chmod 755 $destdir/$bindir/spmk
  cp spmk_pkg $destdir/$bindir/
  for (f in sp spmk_pkg spmk)
    chmod 755 $destdir/$bindir/$f
  touch $destdir/$spmk_mk_d/empty.mk
  cp $subrfiles $destdir/$spmk_inc
  cp spmk.1 $destdir/$mandir
