sample_pkg_ver = 0.1.18-1

sample_pkg:V: sample_pkg-$sample_pkg_ver

sample_pkg-$sample_pkg_ver: dep1 dep2
	. $spkg_header
	gitroot=http://git.example.hg
	fn download.git {
		if (test -d $2)
			cd $name && git pull origin
		if not
			git clone $1 $2
		rm -rf $2-build
		git clone $2 $2-build
	}
	download.git $gitroot $name
	cd $name-build
	mk 'prefix='/usr/local 'CC='$CC 'CFLAGS='-static
	mk 'destdir='$pkgdir 'prefix='/usr/local 'CC='$CC install
	end_pkg
