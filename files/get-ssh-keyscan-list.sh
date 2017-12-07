#!/bin/bash

sqlite3 $1  "SELECT addresses, fqdns, addresses from ssh_keyscan_list;" | sed 's/|/ /; s/|/,/'
