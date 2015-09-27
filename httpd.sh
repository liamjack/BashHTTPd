#!/bin/bash

PROTO=TCP4
SERVERTOKEN="BashHTTPd v1.0"
HTTPVERSION="HTTP/1.1"
WWWPATH="/tmp/www"
FOUROFOURFILE="/404.html"

usage() {
	echo "Usage: $(basename $0) port" >&2
	exit 1
}

contentLengthHeader() {
	contentLength=`wc -c $1 | cut -d ' ' -f 1`
	echo "Content-Length: $contentLength"
}

fileTypeHeader() {
	fileType=`file -ib $1`
	echo "Content-Type: $fileType"
}

getFile() {
	echo $1
	echo "Server: $SERVERTOKEN"
	echo "Connection: close"
	contentLengthHeader $2
	fileTypeHeader $2
	echo ""
	cat $2
	exit 0
}

get() {
	file=$WWWPATH$1

	if test "$1" == "/"; then
		file="$WWWPATH/index.html"
	fi

	if test -e $file; then
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
		POST)
			;;
		HEAD)
			;;
		POST)
			;;
		OPTIONS)
			;;
		CONNECT)
			;;
		TRACE)
			;;
		PUT)
			;;
		PATCH)
			;;
		DELETE)
			;;
		*)
			;;
	esac
done
