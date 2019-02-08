#!/bin/bash
#################################################################
#                                                               #
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.      #
# All rights reserved.                                          #
#                                                               #
#   This source code contains the intellectual property         #
#   of its copyright holder(s), and is made available           #
#   under a license.  If you do not know the terms of           #
#   the license, please stop and do not read further.           #
#                                                               #
#################################################################

# Basic YottaDB environment setup
source /opt/yottadb/gui/env

# Setup the initial Global Directory
/opt/yottadb/current/mumps -run ^GDE < database.gde

# Create databases from the inital Global Directory
/opt/yottadb/current/mupip create

# Start the GUI
cd /opt/yottadb/gui/dist
/opt/yottadb/current/mumps -run ^GDEWEB 8080 SSL

rm -f ~/fifo
mkfifo ~/fifo || exit
chmod 400 ~/fifo
read < ~/fifo
