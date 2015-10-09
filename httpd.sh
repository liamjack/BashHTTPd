#!/bin/bash

PROTO=TCP4
SERVERTOKEN="BashHTTPd v1.0"
HTTPVERSION="HTTP/1.1"
WWWPATH="/tmp/www"
FOUROFOURFILE="/404.html"
FOUROTHREEFILE="/403.html"

usage() {
	echo "Usage: $(basename $0) [PORT]" >&2
	exit 1
}

contentLengthHeader() {
	echo "Content-Length: $(wc -c $1 | cut -d ' ' -f 1)"
}

fileTypeHeader() {
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

	# Check if the request didn't specify a file
	if test "$1" == "/"; then
		# No file specified, default to index.html
		file="$WWWPATH/index.html"
	fi

	# Check if the file exists
	if test -e $file; then
		# Check if the file is a symbolic link
		if test -h $file; then
			# File is a symbolic link
			file="$WWWPATH/$(readlink $file)"
		fi

		# Check if the file is readable
		if test -r $file; then
			# File is readable
			getFile "$HTTPVERSION 200 OK" $file
		else
			# File is not readable: Error 403
			getFile "$HTTPVERSION 403 FORBIDDEN" "$WWWPATH$FOUROTHREEFILE"
		fi
	else
		# File doesn't exist: Error 404
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