# bencview

`bencview` - a .torrent files viewer for terminal pagers.\
`json2bencode` - a converter from JSON to the torrent files format.

(Bencode is a data serialization format used by the BitTorrent network.)

## Installation

(Ruby 2.3.0+)

	$ gem install bencview

Add to your `lesspipe.sh`:

<pre>
case "$1" in
...
<b>    *.torrent) bencview "$1" ;;</b>
...
esac
</pre>

Optionally:

	$ npm -g i json

## Usage

View a torrent file:

~~~
$ bencview gimp.torrent
infohash: a85b7e7f035c55f684238d0e252b273fe2a1ccf5
uri: magnet:?xt=urn:btih:a85b7e7f035c55f684238d0e252b273fe2a1ccf5&dn=gimp-2.8.14-setup-1.exe.torrent
announce: udp://tracker.publicbt.com:80
announce-list: 2
 udp://tracker.publicbt.com:80
 udp://tracker.openbittorrent.com:80
comment: GIMP 2.8.14 Installer for Microsoft Windows - updated
created by: mktorrent 1.0
creation date: Tue, 2 Sep 2014 22:05:50 +0000
url-list: 34
 http://gimper.net/downloads/pub/gimp/v2.8/windows
 http://gimp.afri.cc/pub/gimp/v2.8/windows
 [...]
info/name: gimp-2.8.14-setup-1.exe
info/files: 1
 91,931,728 gimp-2.8.14-setup-1.exe
info/files size: 91,931,728
~~~

Remove all trackers from it:

~~~
$ bencview -j gimp.torrent | json -e 'delete this.announce; delete this["announce-list"]' | json2bencode > file.torrent

$ file file.torrent
file.torrent: BitTorrent file

$ bencview file.torrent
infohash: a85b7e7f035c55f684238d0e252b273fe2a1ccf5
uri: magnet:?xt=urn:btih:a85b7e7f035c55f684238d0e252b273fe2a1ccf5&dn=gimp-2.8.14-setup-1.exe.torrent
comment: GIMP 2.8.14 Installer for Microsoft Windows - updated
created by: mktorrent 1.0
creation date: Tue, 2 Sep 2014 22:05:50 +0000
url-list: 34
 http://gimper.net/downloads/pub/gimp/v2.8/windows
 http://gimp.afri.cc/pub/gimp/v2.8/windows
 [...]
info/name: gimp-2.8.14-setup-1.exe
info/files: 1
 91,931,728 gimp-2.8.14-setup-1.exe
info/files size: 91,931,728
~~~

Note that the infohash hasn't changed.

## History

This is a complete rewrite of the original
bencview-0.0.x. `bencview_clean` util is gone, for `bencview` can
export torrent files into JSON.

1.0.0 version is also ~2 times smaller.

## Bugs

* Both utils assume the UTF8 locale.

## License

MIT.
