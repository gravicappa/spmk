sample_pkg_ver = 0.1.18-1

sample-pkg:V: sample-pkg-$sample_pkg_ver

sample-pkg-$sample_pkg_ver: dep1 dep2
  __PACKAGE__
  . $spmk_inc/vcs
  gitroot=http://git.example.hg
  download_git $gitroot $name $sample_pkg_ver
  cd $name-build
  opts=('prefix='/usr/local 'CC='$CC 'CFLAGS='-static 'destdir='$pkgdir)
  mk $opts all install
