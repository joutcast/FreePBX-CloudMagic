## Maintainer Christopher Lock <joutcast@gmail.com> v0.001-Z
##Incredibly Elastix docker file
MAINTAINER Christopher Lock <joutcast@gmail.com> v0.001-Z
FROM alpine:3.5.2

##LIGHTTPD AND PHP INSTALL
RUN apk add --no-cache lighttpd php5-common php5-iconv php5-json php5-gd php5-curl php5-xml php5-pgsql php5-imap php5-cgi fcgi
RUN apk add --no-cache php5-pdo php5-pdo_pgsql php5-soap php5-xmlrpc php5-posix php5-mcrypt php5-gettext php5-ldap php5-ctype php5-dom

RUN /bin/sh "sed -i '/^#.* include "mod_fastcgi.conf" /s/^#//' /etc/lighttpd/lighttpd.conf"

RUN /bin/sh rc-service lighttpd start && rc-update add lighttpd default

##INSTALL PEAR DB
RUN apk add --no-cache php5-pear; pear install DB

##INSTALL MYSQL CLIENT
RUN apk add --no-cache mysql mysql-client

##START MYSQL MYSQL-CLIENT
RUN /usr/bin/mysql_install_db --user=mysql
RUN /usr/bin/mysqladmin -u root password 'passw0rd'

##INSTALL ASTERISK
RUN apk add --no-cache asterisk asterisk-sample-config dahdi-linux-vserver asterisk-addons-mysql

##START ASTERISK
RUN /etc/init.d/asterisk start

##INSTALL FREEPBX
RUN /bin/sh wget http://mirror.freepbx.org/modules/packages/freepbx/freepbx-13.0-latest.tgz
RUN /bin/sh tar zxvf freepbx-13.0-latest.tgz && cd freepbx-13.0-latest

##ADD FREEPBX DB TO MYSQL
RUN /bin/sh mysqladmin create asterisk -p
RUN /bin/sh mysqladmin create asteriskcdrdb -p
RUN /bin/sh mysql -D asterisk -u root -p < SQL/newinstall.sql
RUN /bin/sh mysql -D asteriskcdrdb -u root -p < SQL/cdr_mysql_table.sql
RUN /bin/sh mysql -uroot -ppassw0rd GRANT ALL PRIVILEGES ON asterisk.* TO asteriskuser@localhost IDENTIFIED BY 'amp109'; exit
RUN /bin/sh mysql -uroot -ppassw0rd GRANT ALL PRIVILEGES ON asteriskcdrdb.* TO asteriskuser@localhost IDENTIFIED BY 'amp109'; exit

##ADD SED patch
RUN apk add --no-cache sed patch

##INSTALL PERL FOR FPO
RUN apk add --no-cache apk add perl

##RUN INSTALLER
RUN /bin/sh ./install_amp -y

##CHANGE GROUPNAME & USERNAME 'lighttpd' TO 'asterisk'
RUN /bin/sh groupmod --new-name asterisk lighttpd
RUN /bin/sh usermod --new-name asterisk lighttpd

##ADJUST PERMISSIONS FOR FREEPBX
RUN /etc/init.d/lighttpd stop
RUN chown -R asterisk:asterisk /var/log/lighttpd
RUN chown -R asterisk:asterisk /var/run/lighttpd*
RUN chown -R asterisk:asterisk /var/www/localhost/htdocs/freepbx
RUN /etc/init.d/lighttpd start

##APPLY PATCH FOR FREEPBX
RUN /etc/init.d/asterisk stop
RUN /bin/sh cd /var/lib/asterisk/bin
RUN patch -p0 < freepbx_engine.patch
RUN /bin/sh cd /var/www/localhost/htdocs/freepbx/admin/modules/framework/bin/
RUN patch -p0 freepbx_engine.patch

##DOWNLOAD & INSTALL AWS ELASTICACHE


##START PORTAL & SERVICES
RUN /bin/sh amportal start
RUN /bin/sh fwconsole start
RUN /bin/sh modprobe dahdi
RUN /bin/sh modprobe dahdi_dummy

##LOAD ON BOOT
RUN /bin/sh echo dahdi >> /etc/modules
RUN /bin/sh echo dahdi_dummy >> /etc/modules
