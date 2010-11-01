spkgdir = /home/ramil/dev/spkg
core_header = . $spkgdir/mkpkg
header = $core_header
testdir = /home/ramil/dev/spkg/test/
ports = $testdir/ports
buildroot = $testdir/build
root = $testdir/root
dbroot = $testdir/packages

default:VQ:
	echo 'Usage: mk [all|<packages>]'

update:VQ:
	#TODO: skip packages that does not exist in $ports any more
	mk `ls | grep '[-]' | sed 's/-[0-9].*$//' | sort | uniq`

vars:VQ:
	echo distfiles: $distfiles
	echo pkgroot: $pkgroot
	echo flags: $MKFLAGS
	echo args: $MKARGS
	echo root: $root

<| cat $ports/*/port.mk
