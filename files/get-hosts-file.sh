#!/bin/bash

sqlite3 $1  "SELECT * from hosts_file;" | sed 's/|/ /; s/|/,/g; s/,/ /g'
