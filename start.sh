#START LIGHTTPD & PHP
dumb-init lighttpd

# start apache
dumb-init apache2 start

# start mysql
/etc/init.d/mysql start
dumb-init mariadb default

# start asterisk
dumb-init asterisk start

#START FREEPBX v.13
dumb-init amportal start
dumb-init fwconsole start
