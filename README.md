SPMK
====
Simple ports and package system.
Features:

  * dependency resolving,
  * support of binary packages,
  * package signing (currently uses openssl, polarssl support is planned).

Ports part implemented in 9base tools (rc, mk). Package management implemented
in portable POSIX sh (busybox compatible) and in rc.

More extensive documentation is not yet written. Look into `sample/build.mk`
as an example of building script.

Requirements
------------

  * 9base, p9p (tested on 9base)
  * openssl (optional, for signing and verifying packages)
  * tar, gzip
  * coreutils (cp, mv, rm)

Installation
------------
To install spmk into `/usr/local/` type

    mk install

You can look into `mkfile` to find installation setting variables such as
`destdir` and `prefix`.

Configuration
-------------
### $prefix/etc/spmk/

The directory contains a private key `priv.key` for signing packages.
Also mk tries to source all `*.mk` files stored in this directory.
These files are supposed to contain settings for build environment
such as general variables like `CC`, `CFLAGS`, etc and system-specific
environment like `SDL_CFLAGS` for instance.

### $prefix/etc/spmk/pubkeys/

The directory contains public keys used for package verification.

Slackware backend
-----------------
To build a package for spmk with slackware backend type `mk` in `slackware`
directory.

Contacts
--------
jid: ramil.fh@jabber.ru
mail: ramil@gmx.co.uk
irc: gravicappa at irc.freenode.net && irc.oftc.net
