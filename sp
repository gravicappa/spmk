#!/bin/sh

root="${SPMK_ROOT:-$HOME/dev/spmk/root}"
pkgdb="${SPMK_DB:-$root/var/lib/spmk}"
tmpdir="$root/tmp/spmk"
pubkeydir="$root/keys"
exclude="$root/etc/spmk/exclude"
noverify=
save="$root/etc/spmk/save"

die() {
  echo "$1" >&2
  exit 1
}

verify() {
  for k in "$pubkeydir"/*; do
    if openssl dgst -sha1 -verify "$k" -signature "$2" <"$1" >/dev/null; then
      return
    fi
  done
  false
}

current_version() {
  for f in "$pkgdb"/"$1"-[0-9]*; do
    basename "$f"
    break
  done
}

excluded() {
  eval "$(echo "case '$1' in "
          sed 's/^.*$/&) true;;/' <"$exclude"
          echo '*) false;; esac')"
}

remove_files() {
  awk '{print NR " " $0}' | sort -r -n | sed 's/^[0-9]* //' \
  | while IFS='' read -r f; do
    if test -f "$exclude" && excluded "$f"; then
      mv "$root/$f" "$root/$f.saved"
    elif test -f "$root/$f"; then
      rm -f "$root/$f"
    elif test -d "$root/$f"; then
      rmdir "$root/$f" 2>/dev/null || true
    fi
  done
}

add() {
  pkgfile="$1"
  pkg="$(basename "$pkgfile" | sed 's/-[^-]*$//')"
  pkgname="$(echo "$pkg" | sed 's/-[0-9].*$//')"
  tmp="$tmpdir/$pkg"

  if test -z "$noverify" ; then
    test -f "$pkgfile.sig" || die "Package '$pkgfile' not signed."
    verify "$pkgfile" "$pkgfile.sig" || die "Package '$pkgfile' is corrupted."
  fi

  rm -rf "$tmp"
  mkdir -p "$tmp" || die "Cannot create temp directory '$tmp'"
  excl="$tmpdir/exclude"
  echo '+PKG' >"$excl"
  test -f "$exclude" && cat "$exclude" >>"$excl"
  trap "rm -rf '$excl' '$tmp'" EXIT HUP INT QUIT ABRT

  gunzip <"$pkgfile" | (cd "$tmp"; tar -x -f - "+PKG") \
  || die "Broken package."
  gunzip <"$pkgfile" | tar -t -f - -X "$excl" | grep -v '^+PKG' \
  >$tmp/files || die "Broken package."

  remove "$pkgname" :

  if test -z "$force"; then
    while IFS='' read -r f ; do
      case "$f" in
        */) check='-f' ;;
        *) check='-e' ;;
      esac
      if test $check "$root/$f"; then
        echo "error: File '$root/$f' already exists." >&2
        s=error
      fi
    done <"$tmp/files"
    test "$s" = error && die 'Aborting install.'
  fi

  if ! gunzip <"$pkgfile" | (cd "$root" && tar -x -f - -X "$excl") ; then
    remove_files <"$tmp/files"
    die "Couldn't unpack contents of '$pkgfile'"
  fi

  if test -z "$sp_no_script" && test -f "$tmp/+PKG/install" ; then
    sh -c ". '$tmp/+PKG/install'" || {
      remove_files <"$tmp/files"
      die 'Error in install script.'
    }
  fi

  mkdir -p "$pkgdb/$pkg"
  test -n "$reason" && echo "reason: $reason" >>"$tmp/+PKG/info"
  echo "files:" >>"$tmp/+PKG/info"
  gunzip <"$pkgfile" | tar -t -f - | grep -v '^+PKG' >>"$tmp/+PKG/info"
  cp "$tmp/+PKG"/* "$pkgdb/$pkg"
  rm -rf "$excl" "$tmp"
  trap - EXIT HUP INT QUIT ABRT
}

remove() {
  pkg="$1"
  test -d "$pkgdb/$pkg" || pkg="$(current_version "$1")"
  if test -d "$pkgdb/$pkg"; then
    if test -z "$sp_no_script" && test -f "$pkgdb/$pkg/uninstall" ; then
      sh -c ". '$pkgdb/$pkg/uninstall'" || die 'Error in uninstall script.'
    fi
    sed '1,/^files:/d' <"$pkgdb/$pkg/info" | remove_files
    rm -rf "$pkgdb/$pkg"
  else
    ${2:-die} "Cannot find package '$1'."
  fi
}

cmd='add'
while test $# -gt 0; do
  case "$1" in
    -n) noverify='yes'; shift;;
    -f) force='yes'; shift;;
    -e) reason='dependency'; shift;;
    -[ai]) cmd=add; shift;;
    -[dr]) cmd=remove; shift;;
    -*) die 'usage: sp [-a] [-r] [-n] [-f] [-e] pkg...';;
    *) break;;
  esac
done
for a; do $cmd "$@"; done
