#!/usr/bin/env rc

root=$HOME/dev/spmk/root
test -n $"SPMK_ROOT && root=$"SPMK_ROOT
pkgdb=$root/var/lib/spmk
test -n $"SPMK_DB && pkgdb=$"SPMK_DB
tmpdir=$root/tmp/spmk
pubkeydir=$root/keys
exclude=$root/etc/spmk/exclude
noverify=()
save=$root/etc/spmk/save

fn die {
  echo $1 >[1=2]
  exit 1
}

fn verify {
  s=false
  for (k in $pubkeydir/*)
    if (openssl dgst -sha1 -verify $k -signature $2 <$1 >/dev/null)
      s=true
  $s
}

fn excluded {
  eval `{echo 'switch ('$1') {'
         sed 's/^.*$/case &;\n  true;/' <$exclude
         echo 'case *;  false}'}
}

fn remove_files {
  awk '{print NR " " $0}' | sort -r -n | sed 's/^[0-9]* //' \
  | while (f=`{ifs='' read}) {
      if (test -f $exclude && excluded $f && test -f $root/$f)
        mv $root/$f $root/$f.saved
      if not {
        if (test -f $root/$f)
          rm -f $root/$f
        if not
          if (test -d $root/$f)
            rmdir $root/$f >[2]/dev/null || true
      }
  }
}

fn add {
  pkgfile=$1
  pkg=`{basename $"pkgfile | sed 's/-[^-]*$//'}
  pkgname=`{echo $"pkg | sed 's/-[0-9].*$//'}
  tmp=$tmpdir/$pkg

  if (test -z $"noverify) {
    test -f $pkgfile.sig || die 'Package '''$pkgfile''' not signed.'
    verify $pkgfile $pkgfile.sig || die 'Package '''$pkgfile''' is corrupted.'
  }

  rm -rf $tmp
  mkdir -p $tmp || die 'Cannot create temp directory '''$tmp''''
  excl=$tmpdir/exclude
  echo '+PKG' >$excl
  test -f $exclude && cat $exclude >>$excl
  fn sigexit {rm -rf $excl $tmp}

  gunzip <$pkgfile | @{cd $tmp && tar -x -f - +PKG} || die 'Broken package.'
  gunzip <$pkgfile | tar -t -f - -X $excl | grep -v '^+PKG' \
  >$tmp/files || die 'Broken package.'

  remove $pkgname >[2]/dev/null

  if (test -z $"force) {
    s=ok
    {
      while (f=`{ifs='' read}) {
        switch ($f) {
        case */
          check='-f'
        case *
          check='-e'
        }
        if (test $check $root/$f) {
          echo 'error: File '''$root/$f''' already exists.' >[1=2]
          s=error
        }
      }
    } <$tmp/files
    test $s '=' error && die 'Aborting install.'
  }

  if (! gunzip <$pkgfile | @{cd $root && tar -x -f - -X $excl}) {
    remove_files <$tmp/files
    die 'Couldn''t unpack contents of '''$pkgfile''''
  }
  if (test -z $"sp_no_script && test -f $tmp/+PKG/install.rc)
    rc <$tmp/+PKG/install.rc || {
      remove_files <$tmp/files
      die 'Error in install script.'
    }
  mkdir -p $pkgdb/$pkg
  test -n $"reason && echo reason: $reason >>$tmp/+PKG/info
  echo files: >>$tmp/+PKG/info
  gunzip <$pkgfile | tar -t -f - | grep -v '^+PKG' >>$tmp/+PKG/info
  cp $tmp/+PKG/* $pkgdb/$pkg
  rm -rf $excl $tmp
  fn sigexit
}

fn remove {
  for (p in $pkgdb/$1 $pkgdb/$1-[0-9]*)
    if (test -d $p) {
      if (test -z $"sp_no_script && test -f $p/uninstall.rc)
        rc <$p/uninstall.rc || echo 'Uninstall script error.' >[1=2]
      sed '1,/^files:/d' <$p/info | remove_files
      rm -rf $p
    }
}

cmd='add'
while (test $#* -gt 0 -a -z $"argend)
  switch ($1) {
  case -n
    noverify='yes'
    shift
  case -f
    force='yes'
    shift
  case -e
    reason='dependency'
    shift
  case -[ai]
    cmd=add
    shift
  case -[dr]
    cmd=remove
    shift
  case -*
    die 'usage: sp [-a] [-r] [-n] [-f] [-e] pkg...'
  case *
    argend=1
  }
for (a) $cmd $a
