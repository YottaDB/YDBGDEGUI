#################################################################
#								#
# Copyright (c) 2018-2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#   This source code contains the intellectual property		#
#   of its copyright holder(s), and is made available		#
#   under a license.  If you do not know the terms of		#
#   the license, please stop and do not read further.		#
#								#
#################################################################

FROM yottadb/yottadb-base:latest-master

WORKDIR /opt/yottadb/gui
COPY . /opt/yottadb/gui

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    bzip2 \
    curl \
    libgcrypt11-dev \
    libgpgme11-dev \
    libconfig-dev \
    libssl-dev \
    cmake \
    git && \
    apt-get clean

# Install ydb_crypt plugin
RUN mkdir /tmp/plugin-build && \
    cd /tmp/plugin-build && \
    cp /opt/yottadb/current/plugin/gtmcrypt/source.tar . && \
    tar -xf source.tar && \
    . /opt/yottadb/gui/env && \
    make && make install && make clean && \
    find $ydb_dist/plugin -type f -exec chown root:root {} +

# Build certificate for SSL/TLS purposes
#RUN openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes -keyout ydbgui.key -out ydbgui.crt -subj /CN=localhost -passout pass:ydbgui

RUN openssl genrsa -aes128 -passout pass:ydbgui -out /opt/yottadb/gui/ydbgui.key 2048
RUN openssl req -new -key /opt/yottadb/gui/ydbgui.key -passin pass:ydbgui -subj '/C=US/ST=Pennsylvania/L=Malvern/CN=localhost' -out /opt/yottadb/gui/ydbgui.csr
RUN openssl req -x509 -days 365 -sha256 -in /opt/yottadb/gui/ydbgui.csr -key /opt/yottadb/gui/ydbgui.key -passin pass:ydbgui -out /opt/yottadb/gui/ydbgui.pem

# Install node.js
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash && \
    . $HOME/.nvm/nvm.sh && \
    nvm install --lts

# Install M Web Server, M-Unit, and GDE GUI for both M and UTF-8 modes
RUN . /opt/yottadb/gui/env && \
    for pkg in M-Web-Server M-Unit GUI; \
    do \
        option=MUMPS && \
        cd /opt/yottadb && \
        if [ "$pkg" = "M-Web-Server" ]; \
        then \
            git clone https://github.com/shabiel/M-Web-Server.git; \
            cd $pkg; \
        elif [ "$pkg" = "M-Unit" ]; \
        then \
            git clone https://github.com/ChristopherEdwards/M-Unit.git; \
            cd $pkg; \
        else \
            option=M; \
            cd /opt/yottadb/gui; \
        fi && \
        mkdir cmake-build && \
        cd cmake-build && \
        cmake .. && \
        make && \
        make install && \
        cd .. && \
        mkdir cmake-build-utf8 && \
        cd cmake-build-utf8 && \
        cmake -D${option}_UTF8_MODE=1 .. && \
        make && \
        make install; \
    done

EXPOSE 8080

ENTRYPOINT ["/opt/yottadb/gui/start.sh"]
