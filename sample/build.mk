sample_pkg_ver = 0.1.18-1

sample-pkg:V: sample-pkg-$sample_pkg_ver

sample-pkg-$sample_pkg_ver: dep1 dep2
	. $spmk_inc/main
	. $spmk_inc/vcs
	gitroot=http://git.example.hg
	download_git $gitroot $name $sample_pkg_ver
	cd $name-build
	mk 'prefix='/usr/local 'CC='$CC 'CFLAGS='-static
	mk 'destdir='$pkgdir 'prefix='/usr/local 'CC='$CC install
