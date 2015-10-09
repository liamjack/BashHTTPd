#!/bin/bash

PROTO=TCP4
SERVERTOKEN="BashHTTPd v1.0"
HTTPVERSION="HTTP/1.1"
WWWPATH="/tmp/www"
FOUROFOURFILE="/404.html"

usage() {
	echo "Usage: $(basename $0) [PORT]" >&2
	exit 1
}

contentLengthHeader() {
	echo "Content-Length: $(wc -c $1 | cut -d ' ' -f 1)"
}

fileTypeHeader() {
	fileType=``
	echo "Content-Type: $(file -ib $1)"
}

getHeader() {
	echo $1
	echo "Server: $SERVERTOKEN"
	echo "Connection: close"
}

getFile() {
	getHeader $1
	
	if test "$2" != ""; then
		contentLengthHeader $2
		fileTypeHeader $2
		echo ""
		cat $2
	fi
	
	exit 0
}

get() {
	file=$WWWPATH$1

	if test "$1" == "/"; then
		file="$WWWPATH/index.html"
	fi

	if test -e $file; then
		if test -h $file; then
			file="$WWWPATH/$(readlink $file)"
		fi
		
		getFile "$HTTPVERSION 200 OK" $file
	else
		getFile "$HTTPVERSION 404 NOT FOUND" "$WWWPATH$FOUROFOURFILE"
	fi
}

if ! echo $@ | grep -q -- '--script'; then
	if [ $# -ne 1 ]; then
		usage
	fi

	socat $PROTO-LISTEN:$1,fork exec:"$0 --script"
	exit 0
fi

while read line; do
	HttpMethod=`echo $line | cut -d ' ' -f 1`
	HttpUri=`echo $line | cut -d ' ' -f 2`
	HttpVersion=`echo $line | cut -d ' ' -f 3`

	case "$HttpMethod" in
		GET)
			get $HttpUri
			;;
		*)
			getHeader "$HTTPVERSION 501 NOT IMPLEMENTED"
			exit 0
			;;
	esac
done