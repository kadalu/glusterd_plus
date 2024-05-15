# Glusterd Plus

## Debian packaging

TODO: Build binary while creating the package itself (`debuild`). Now it is failing to build the binaries.

Release build

```
make releasebuild
```

Now create the Debian package

```
VERSION=0.1.0 make deb
```

To see the generated files,

```console
$ dpkg -c glusterdplus_0.1.0-1_amd64.deb
drwxr-xr-x root/root         0 2024-05-12 19:30 ./
drwxr-xr-x root/root         0 2024-05-12 19:30 ./lib/
drwxr-xr-x root/root         0 2024-05-12 19:30 ./lib/systemd/
drwxr-xr-x root/root         0 2024-05-12 19:30 ./lib/systemd/system/
-rwxr-xr-x root/root       212 2024-05-12 19:30 ./lib/systemd/system/glusterdplus.service
drwxr-xr-x root/root         0 2024-05-12 19:30 ./usr/
drwxr-xr-x root/root         0 2024-05-12 19:30 ./usr/sbin/
-rwxr-xr-x root/root   3054496 2024-05-12 19:30 ./usr/sbin/glusterdplus
drwxr-xr-x root/root         0 2024-05-12 19:30 ./usr/share/
drwxr-xr-x root/root         0 2024-05-12 19:30 ./usr/share/doc/
drwxr-xr-x root/root         0 2024-05-12 19:30 ./usr/share/doc/glusterdplus/
-rw-r--r-- root/root       138 2024-05-12 19:30 ./usr/share/doc/glusterdplus/README.Debian
-rw-r--r-- root/root       166 2024-05-12 19:30 ./usr/share/doc/glusterdplus/changelog.Debian.gz
-rw-r--r-- root/root       298 2024-05-12 19:30 ./usr/share/doc/glusterdplus/copyright
drwxr-xr-x root/root         0 2024-05-12 19:30 ./var/
drwxr-xr-x root/root         0 2024-05-12 19:30 ./var/lib/
drwxr-xr-x root/root         0 2024-05-12 19:30 ./var/lib/glusterdplus/
drwxr-xr-x root/root         0 2024-05-12 19:30 ./var/lib/glusterdplus/public/
drwxr-xr-x root/root         0 2024-05-12 19:30 ./var/lib/glusterdplus/public/images/
-rw-r--r-- root/root     14539 2024-05-12 19:30 ./var/lib/glusterdplus/public/images/logo.png
drwxr-xr-x root/root         0 2024-05-12 19:30 ./var/lib/glusterdplus/public/js/
-rw-r--r-- root/root       675 2024-05-12 19:30 ./var/lib/glusterdplus/public/js/app.js
-rw-r--r-- root/root       332 2024-05-12 19:30 ./var/lib/glusterdplus/public/js/peers.js
-rw-r--r-- root/root       338 2024-05-12 19:30 ./var/lib/glusterdplus/public/js/volumes.js
```

Package info:

```console
$ dpkg -I glusterdplus_0.1.0-1_amd64.deb
 new Debian package, version 2.0.
 size 862184 bytes: control archive=1466 bytes.
     513 bytes,    13 lines      control
     657 bytes,     9 lines      md5sums
    1365 bytes,    32 lines   *  postinst             #!/bin/sh
     681 bytes,    21 lines   *  postrm               #!/bin/sh
     260 bytes,     7 lines   *  prerm                #!/bin/sh
 Package: glusterdplus
 Version: 0.1.0-1
 Architecture: amd64
 Maintainer: Kadalu Technologies Private Limited <packaging@kadalu.tech>
 Installed-Size: 3025
 Depends: libc6 (>= 2.34), libgcc-s1 (>= 4.2), libssl3 (>= 3.0.0~~alpha1), zlib1g (>= 1:1.1.4)
 Section: main
 Priority: optional
 Multi-Arch: foreign
 Homepage: <https://github.com/kadalu/glusterd_plus>
 Description: Enhanced Glusterd - Gluster FS.
              It adds the modern features to Glusterd like ReST APIs,
              Web console and metrics exporters.
```
