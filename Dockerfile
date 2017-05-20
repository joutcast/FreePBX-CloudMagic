## Maintainer Christopher Lock <joutcast@gmail.com> v0.001-Z
##FREEPBX-CloudMagic AWS ELASTICACHE & BUILT AS A CONTAINER SERVICE
MAINTAINER Christopher Lock <joutcast@gmail.com> v0.001-Z
FROM alpine:3.5-slim
CMD ["/sbin/my_init"]
##SIP PORTS
EXPOSE 10000-20000/udp
Expose 5060/udp
EXPOSE 5061/tcp
EXPOSE 5061/UDP
##YOU NEED TO ASK?....REALLY?
Expose 80
Expose 8088
##GOOGLE VOICE CONNECTIONS
EXPOSE 19302-19309/UDP
EXPOSE 19302-19309/TCP

##SET WORKING DIR
WORKDIR /root/

##UPDATE APK REPO
CMD apk update -y

##INSTALL CORE DEPENDENCIES WGET BUILD-ESSENTIALS SSH AND OTHER BASIC BUILDING BLOCKS
RUN apk add --no-cache wget build-essential ssh python dumb-init bash ca-certificates python3.4 npm

##INSTALL CORE DEPENDENCIES LIGHTTPD AND PHP
RUN apk add --no-cache lighttpd php5-common php5-iconv php5-json php5-gd php5-curl php5-xml php5-pgsql php5-imap php5-cgi fcgi
RUN apk add --no-cache php5-pdo php5-pdo_pgsql php5-soap php5-xmlrpc php5-posix php5-mcrypt php5-gettext php5-ldap php5-ctype php5-dom

##CONFIGURE CORE DEPENDENCIES
CMD "sed -i '/^#.* include "mod_fastcgi.conf" /s/^#//' /etc/lighttpd/lighttpd.conf"

CMD rc-service lighttpd start && rc-update add lighttpd default

##INSTALL CORE DEPENDENCIES PEAR
RUN apk add --no-cache php5-pear; pear install DB

##INSTALL CORE DEPENDENCIES MYSQL-CLIENT
RUN apk add --no-cache mysql mysql-client

##CONFIGURE CORE DEPENDENCY MYSQL-CLIENT
RUN /usr/bin/mysql_install_db --user=mysql
RUN /usr/bin/mysqladmin -u root password 'passw0rd'

##INSTALL DEPENDENCY CHILD OBJECTS
CMD npm install node.js
CMD npm install elasticache-client
CMD npm install prompt
##OPTINAL CMD npm install aws-serverless-express

##AWS ELASTICACHE CONFIG
CMD var Memcached = require('elasticache-client');
CMD var prompt = require('prompt')
  prompt.start();
  prompt.get(new Memcached['Server Locations', 'config', 'options'], function (err, result) {
    console.log('Command-line input received:');
    console.log('  Server locations: ' + result.Server locations);
    console.log('  config: ' + result.config);
    console.log('  options: ' + result.options);
CMD var memcached = new Memcached(Server locations, config, options); 
});


##INSTALL ASTERISK
RUN apk add --no-cache asterisk asterisk-sample-config dahdi-linux-vserver asterisk-addons-mysql

##START ASTERISK
CMD asterisk start

##INSTALL FREEPBX
CMD wget http://mirror.freepbx.org/modules/packages/freepbx/freepbx-13.0-latest.tgz
CMD tar zxvf freepbx-13.0-latest.tgz && cd freepbx-13.0-latest

##ADD FREEPBX DB TO MYSQL
CMD mysqladmin create asterisk -p
CMD mysqladmin create asteriskcdrdb -p
CMD mysql -D asterisk -u root -p < SQL/newinstall.sql
CMD mysql -D asteriskcdrdb -u root -p < SQL/cdr_mysql_table.sql
CMD mysql -uroot -ppassw0rd GRANT ALL PRIVILEGES ON asterisk.* TO asteriskuser@localhost IDENTIFIED BY 'amp109'; exit
CMD mysql -uroot -ppassw0rd GRANT ALL PRIVILEGES ON asteriskcdrdb.* TO asteriskuser@localhost IDENTIFIED BY 'amp109'; exit

##ADD SED patch
RUN apk add --no-cache sed patch

##INSTALL PERL FOR FPO
RUN apk add --no-cache apk add perl

##RUN INSTALLER
CMD ./install_amp

##CHANGE GROUPNAME & USERNAME 'lighttpd' TO 'asterisk'
CMD groupmod --new-name asterisk lighttpd
CMD usermod --new-name asterisk lighttpd

##ADJUST PERMISSIONS FOR FREEPBX
RUN /etc/init.d/lighttpd stop
CMD chown -R asterisk:asterisk /var/log/lighttpd
CMD chown -R asterisk:asterisk /var/run/lighttpd*
CMD chown -R asterisk:asterisk /var/www/localhost/htdocs/freepbx
RUN /etc/init.d/lighttpd start

##APPLY PATCH FOR FREEPBX
RUN /etc/init.d/asterisk stop
RUN /bin/sh cd /var/lib/asterisk/bin
CMD patch -p0 < freepbx_engine.patch
RUN /bin/sh cd /var/www/localhost/htdocs/freepbx/admin/modules/framework/bin/
CMD patch -p0 freepbx_engine.patch

##DOWNLOAD & INSTALL AWS ELASTICACHE
##RUN /bin/sh wget https://elasticache-downloads.s3.amazonaws.com/ClusterClient/PHP-7.0/latest-64bit

##INSTALL NPM & NODE.JS
RUN apk add --no-cache --virtual 

##START PORTAL & SERVICES
CMD amportal start
CMD fwconsole start
CMD modprobe dahdi
CMD modprobe dahdi_dummy

##LOAD ON BOOT
CMD echo dahdi >> /etc/modules
CMD echo dahdi_dummy >> /etc/modules

# ADD start.sh /root/
CMD amportal start
CMD fwconsole start
