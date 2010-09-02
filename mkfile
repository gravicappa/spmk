mkpkg = . ../mkpkg
ports = ../ports
mkpkg_headers =

default:VQ:
	echo Usage: mk package

<| cat $ports/*/port.mk
