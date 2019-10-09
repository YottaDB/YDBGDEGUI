# YottaDB Global Directory GUI

The YottaDB Global Directory GUI is a browser based application that can be used to manage Global Directories for YottaDB. The GUI is designed to a quick way to perform edits to Global Directory files, visualize Global Mappings and manage the database files used to store Globals.

## Installation

You will only use one of the below directions (Docker Container OR Manual Setup).

### Docker Container

A docker container is available on docker hub as `yottadb/yottadbgui` which contains the latest version of the GUI pre-built in production mode. It is primarily designed for demo purposes, future versions may allow for more functionality.

There is only one exposed port `8080` which all webservices and the GUI itself runs on. In the command below it is port forwarded to port `8089`, you can change this on your own local system if there are conflicts or if you want the GUI on a different port.

#### Build Docker Container from source

This requires the whole repository to be checked out to build.

```bash
docker build -t yottadb/yottadbgui:latest .
docker run -itd -p 8089:8080 --name ydbgui yottadb/yottadbgui:latest
```

To use the GUI go to https://localhost:8089 in a web browser.
The default username/password is admin/admin.

### Manual Setup

The GUI has two parts:

1. MUMPS based routines that provide the web services and web server
2. HTML, CSS, and JavaScript that provide the actual GUI interface

#### Dependencies

The GUI project relies upon the following dependencies:

1. ydb-crypt
2. Node.js
3. M-Web-Server
4. M-Unit

In the instructions below you may need to subistute the full path for `$ydb_dist` if the environment variable defined it should be set to the directory where YottaDB is installed.

##### Installing ydb-crypt

The ydb-crypt plugin is used to provide SSL/TLS support for the M-Web-Server. These directions are adapted from the official installation instructions for [ydb-crypt](https://docs.yottadb.com/AdminOpsGuide/encryption.html#plugin-architecture-and-interface).

```bash
mkdir /tmp/plugin-build
cd /tmp/plugin-build
cp /opt/yottadb/current/plugin/gtmcrypt/source.tar .
tar -xf source.tar
source $ydb_dist/ydb_env_set
make && make install && make clean
```

##### Installing Node.js

The suggested installation of Node.js is to use [NVM](https://github.com/nvm-sh/nvm). It is recommended to install the latest long term support (lts) version of Node.js.

```bash
cd /tmp
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
source $HOME/.nvm/nvm.sh
nvm install --lts
```

##### Installing M-Web-Server

Since we use the [M-Web-Server](https://github.com/shabiel/M-Web-Server) as a YottaDB plugin we use the installation steps detailed below:

```bash
cd /tmp
source $ydb_dist/ydb_env_set
git clone https://github.com/shabiel/M-Web-Server.git
cd M-Web-Server
mkdir build
cd build
cmake ../
make && make install
```

##### Installing M-Unit (optional)

M-Unit is a development dependency that is used to test the M code for the GUI. This also installs as a YottaDB plugin.

```bash
cd /tmp
source $ydb_dist/ydb_env_set
git clone https://github.com/ChristopherEdwards/M-Unit.git
cd M-Unit
mkdir build
cd build
cmake ../
make && make install
```

#### Installing the GUI

The GUI is packaged as a YottaDB plugin and installed with the following steps which assume that you are in the directory in which you cloned this repository OR where you unpacked a tarball containing the code in this repository.

```bash
source $ydb_dist/ydb_env_set
mkdir cmake-build
cd cmake-build
cmake ../
make && make install
```

#### Starting the GUI

The GUI requires that the webserver is started and running. To start the webserver perform the following steps:

```bash
# Subsitutue NOSSL with SSL if you have setup the necessary SSL setup
# If you encounter issues with no data showing up in the gui you may need to add NOGZIP
cd dist
export ydb_lct_stdnull=1
export ydb_local_collate=0 # Note: this is the default
$ydb_dist/mumps -run ^GDEWEB 8080 NOSSL GZIP admin:admin
```

8080 is the port number in which to start the web server and can be adjusted to any port number that is available on your system.
admin:admin is the username:password to use for authentication and can be set to a combination you desire.

## Development

The YottaDB Global Directory GUI is built using [vue.js](https://vuejs.org/). It uses [webpack](https://webpack.js.org/) to build the application for both development and production targets.

### Build Setup

```bash
# install dependencies
npm install

# build for local development with hot reload
# THIS ASSUMES THAT YOU HAVE THE M-WEB-SERVER/APIS running on https://localhost:8089
npm run dev

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

## Architecture

The GUI is built as two different parts:

1. The backend - written in M
2. The frontend - written in HTML, JavaScript, and CSS

### Backend

The backend is written fully in M. It depends on the [M-Web-Server](http://github.com/shabiel/M-Web-Server) and [M-Unit](http://github.com/ChristopherEdwards/M-Unit). The backend is all Web Services based and uses M-Web-Server functionality to server JSON based responses to web queries. Many changes were submitted to the M-Web-Server project to allow for various requirements of this software including:

* Ability to run without using globals
* Basic CORS support
* Ability to override a specific routine for URL mapping
* Ability to pass a username/password to the web server

#### Webservices

All of the webservices are defined in `_weburl.m` which basically implement CRUD (Create, Read, Update, Delete) functionality for the YottaDB global directory. The actual implementation of the webservices is in `GDEWEB.m` and highly relies upon functionality inside of GDE (and changes made in r1.24 of YottaDB).

The acutal implementation in `GDEWEB.m` is documented and contains examples of how to call each entry point. This basically creates a silent API for the `GDE` application and can be used without the M-Web-Server running if the entire application is M based.

#### Tests

Unit tests are created for all of the entry points in `GDEWEB.m` and the tests live in the routine `GDEWEBT.m` The tests follow M-Unit conventions and also provide more examples of how to use the APIs/Web Services in `GDEWEB.m`. There is also lots of negative/error case testing that is part of the tests performed.

### Frontend

The front end is a [Vue.js](https://vuejs.org/) application built using [Node.js](https://nodejs.org) and [webpack](https://webpack.js.org/) to create a production application. Using Node.js and webpack allow for easier dependency management and ability to compress/minimize the CSS and JavaScript used for the application. At the end of the webpack build process static HTML, JavaScript, and CSS are generated and Node.js and the rest of the dependency tree are not needed for proper operation - all that is needed is the generated `dist` directory.

The frontend is primarly built using [Vue Templates](http://vuejs-templates.github.io) with [Bootstrap Vue](https://bootstrap-vue.js.org) - an integration of bootstrap and Vue.js - and the generic documentation for each of those projects should provide all of the guidance necessary for development and troubleshooting.
