mkpkg_header = . ../mkpkg
mkpkg_headers =
ports = /home/yoda/dev/spkg/ports
buildroot = /home/yoda/dev/spkg/build
root = `{pwd}

default:VQ:
	echo Usage: mk package

vars:VQ:
	echo distfiles: $distfiles
	echo pkgroot: $pkgroot
	echo flags: $MKFLAGS
	echo args: $MKARGS
	echo root: $root

<| cat $ports/*/port.mk || echo
