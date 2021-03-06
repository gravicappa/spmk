MKSHELL = rc

prefix = /usr/local
bindir = $prefix/sbin
etcdir = $prefix/etc
libdir = $prefix/lib
mandir = $prefix/share/man/man1
spimp = rc

root = /
pkgdb = `{cleanname $root/var/lib/spmk}
spmk_mk_d = $etcdir/spmk
pubkeydir = $etcdir/spmk/pubkeys
spmk_privkey = $etcdir/spmk/priv.key
tmpdir = `{cleanname $root/tmp/spmk}
buildroot = `{cleanname $root/tmp/spmk/build}
CC = gcc

<config.mk

all:V: tarchown

install_dirs:VQ:
  mkdir -p $destdir/$bindir $destdir/$etcdir/spmk $destdir/$libdir/spmk
  mkdir -p $destdir/$pubkeydir $destdir/$mandir

install_sp_sh:VQ:
  awk -F'=' '
    /^root=/ {printf("%s=\"${SPMK_ROOT:-%s}\"\n", $1, ENVIRON[$1]); next}
    /^pkgdb=/ {printf("%s=\"${SPMK_DB:-%s}\"\n", $1, ENVIRON[$1]); next}
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
    {print}' <sp.sh >$destdir/$bindir/sp

install_sp_rc:VQ:
  awk -F'=' '
    /^(root|pkgdb|tmpdir|pubkeydir|spmk_privkey)=/ {
      s = sprintf("%s=''%s''", $1, ENVIRON[$1])
      gsub(/\/\/*/, "/", s)
      print s
      next
    }
    /^save=/ {
      s = sprintf("save=''%s/spmk/save''", ENVIRON["etcdir"])
      gsub(/\/\/*/, "/", s)
      print s
      next
    }
    /^exclude=/ {
      s = sprintf("exclude=''%s/spmk/exclude''", ENVIRON["etcdir"])
      gsub(/\/\/*/, "/", s)
      print s
      next
    }
    {print}' <sp >$destdir/$bindir/sp

install:VQ: tarchown install_dirs install_sp_$spimp
  awk -F'=' '/^(spmk_mk_d|pkgdb|root|spmk_privkey|buildroot)=/ {
               printf("%s=''%s''\n", $1, ENVIRON[$1])
               next
             }
             {print}' <spmk >$destdir/$bindir/spmk
  chmod 755 $destdir/$bindir/spmk
  cp spmk_pkg $destdir/$bindir/
  for (f in sp spmk_pkg spmk)
    chmod 755 $destdir/$bindir/$f
  touch $destdir/$spmk_mk_d/empty.mk
  cp spmk.1 $destdir/$mandir
  cp sp.1 $destdir/$mandir
  cp tarchown $destdir/$bindir/

tarchown:Q: tarchown.c
  $CC $CFLAGS -static $prereq $LDFLAGS -o $target
