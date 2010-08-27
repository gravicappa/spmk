mkpkg = . ../mkpkg
mkpkg_plug = ../mkpkg-arch
ports = ../ports
sha1 = /usr/bin/sha1sum

default:VQ:
	echo Usage: mk package

<| cat $ports/*/port.mk
#<| $system_packages
