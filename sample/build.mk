# to simplify changing version number
sample_pkg_ver = 0.1.18-1

sample-pkg:V: sample-pkg-$sample_pkg_ver

sample-pkg-$sample_pkg_ver: dep1 dep2
  # this command sets up package building environment
  # it also sets sigexit handler that packs the contents of
  # $pkgdir into package tarball
  __PACKAGE__
  #
  gitroot=http://git.example.hg
  download_git $gitroot $name $sample_pkg_ver

	# working repo is located in $name-build directory
  cd $name-build

  opts=('prefix='/usr/local 'CC='$CC 'CFLAGS='-static 'destdir='$pkgdir)
  mk $opts all install
  #
  # add install and uninstall scripts to package
  #
  cp $portdir/inst.sh $pkgdir/install.sh
  cp $portdir/uninst.sh $pkgdir/uninstall.sh
  #
  # add rc versions of install and uninstall scripts
  #
  cp inst.rc $pkgdir/install.rc
  cp uninst.rc $pkgdir/uninstall.rc
