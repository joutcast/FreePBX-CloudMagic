#START OPENRC
dumb-init openrc

#START LIGHTTPD & PHP
dumb-init lighttpd

#START APACHE
dumb-init apache2 start

#START NPM
dumb-init npm

# start mysql
dumb-init mysql start
dumb-init mariadb default

# start asterisk
dumb-init asterisk start

#START FREEPBX v.13
CMD fwconsole start
