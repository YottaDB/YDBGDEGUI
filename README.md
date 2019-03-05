# YottaDB Global Directory GUI

The YottaDB Global Directory GUI is a browser based application that can be used to manage Global Directories for YottaDB. The GUI is designed to a quick way to perform edits to Global Directory files, visualize Global Mappings and manage the database files used to store Globals.

# Installation

You will only use one of the below directions (Docker Container OR Manual Setup).

## Docker Container

A docker container is available on docker hub as `yottadb/yottadbgui` which contains the latest version of the GUI pre-built in production mode. It is primarily designed for demo purposes, future versions may allow for more functionality.

There is only one exposed port `8080` which all webservices and the GUI itself runs on. In the command below it is port forwarded to port `8089`, you can change this on your own local system if there are conflicts or if you want the GUI on a different port.

### Build Docker Container from source

This requires the whole repository to be checked out to build.

```bash
docker build -t yottadb/yottadbgui:latest .
docker run -itd -p 8089:8080 --name ydbgui yottadb/yottadbgui:latest
```

To use the GUI go to https://localhost:8089 in a web browser.
The default username/password is admin/admin.

## Manual Setup

The GUI has two parts:

1. MUMPS based routines that provide the web services and web server
2. HTML, CSS, and JavaScript that provide the actual GUI interface

Installing the routines involves copying the contents of the `r` directory to a path contained within your `ydb_routines` search path. You can also add a new directory to your `ydb_routines` search path.

Installing the HTML,CSS, and Javascript requires extracting to a path of your liking and starting the webserver from that path as the webserver looks for all of the required files in the current working directory

To start the webserver:

```bash
# Install dependencies and build
npm install
npm run build

# Compile M programs

# Web server
mkdir webserver/o
cd webserver/o
# ignore any compiler errors here as the webserver supports multiple M implementations
$ydb_dist/mumps ../*.m >/dev/null 2>&1
cd ..

# M-Unit
mkdir munit/o
cd munit/o
# ignore any compiler errors here as the webserver supports multiple M implementations
$ydb_dist/mumps ../*.m >/dev/null 2>&1
cd ..

# GDE GUI
mkdir o
cd /opt/yottadb/gui/o
# Compiler errors are not ignored here as any errors are important
$ydb_dist/mumps ../r/*.m

# Start the webserver
#
# Subsitutue NOSSL with SSL if you have setup the necessary SSL setup
cd dist
export ydb_lct_stdnull=1
export ydb_local_collate=0 # Note: this is the default
$ydb_dist/mumps -run ^GDEWEB 8080 NOSSL admin:admin
```

8080 is the port number in which to start the web server and can be adjusted to any port number that is available on your system.
admin:admin is the username:password to use for authentication and can be set to a combination you desire.

# Development

The YottaDB Global Directory GUI is built using `vue.js <https://vuejs.org/>`_. It uses `webpack <https://webpack.js.org/>`_ to build the application for both development and production targets.

## Build Setup

```bash
# install dependencies
npm install

# build for production with minification
npm run build

# build for production and view the bundle analyzer report
npm run build --report

# run unit tests
npm run unit

# run e2e tests
npm run e2e

# run all tests
npm test
```

For a detailed explanation on how things work, check out the [guide](http://vuejs-templates.github.io/webpack/) and [docs for vue-loader](http://vuejs.github.io/vue-loader).
