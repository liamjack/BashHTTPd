# Description

Very basic and insecure (vulnerable to directory traversal, and probably others) Bash HTTP server.

# Requirements

* `socat`: `sudo apt-get install socat`

# Usage

`./httpd.sh [PORT]`

* `PORT` is the port that you want the HTTP server to run on.

# Configuration

* `PROTO` is the network protocol used (Example: `UDP4` / `UDP6` / `TCP4` / `TCP6`)
* `SERVERTOKEN` is the contents of the `Server` header sent in HTTP responses
* `HTTPVERSION` is the HTTP version sent in HTTP responses
* `WWWPATH` is an absolute path to the directory where HTML files are stored, with *no trailing slash* (Example: `/tmp/www`)
* `FOUROFOURFILE` is the path to the page for 404 errors, relative to `WWWPATH` with preceding slash (Example: `/404.html`)