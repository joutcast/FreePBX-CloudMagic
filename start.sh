#!/bin/bash

#START LIGHTTPD & PHP
--init lighttpd

# start apache
--init apache2 start

# start mysql
/etc/init.d/mysql start
--init mariadb default

# start asterisk
--init asterisk start

#START FREEPBX v.13
--init amportal start
--init fwconsole start
