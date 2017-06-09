## Maintainer Christopher Lock <joutcast@gmail.com> v0.001-Z
##FREEPBX-CloudMagic AWS ELASTICACHE & BUILT AS A CONTAINER SERVICE
FROM alpine:3.5
ENV ASTERISK_PW passw0rd
ENV ASTERISK_USER admin 
MAINTAINER Christopher Lock <joutcast@gmail.com> v0.001-Z
##ADD /crash.sh
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

##UPDATE APK REPO
CMD apk update

##WORKINGDIR FOR THE WORLD
WORKDIR /root

##PREINSTALL APK'S FOR WORLD
RUN apk add --no-cache dumb-init wget bash g++ make

##ADD "dumb-init" TO BOOT
CMD chkconfig dumb-init on

##VIRTUAL GROUP, CREATE WORKING DIRECTORIES OPENRC-PARTS
CMD mkdir /openrc-parts
WORKDIR /openrc-parts
COPY . /openrc-parts


##VIRTUAL GROUP, INSTALL OPENRC APPLICATION
CMD mkdir -p /etc/apk && echo "http://alpine.gliderlabs.com/alpine/edge/main" > /etc/apk/repositories 

RUN apk add --no-cache  --virtual openrc

##CONFIGURE OPENRC VIRTUAL GROUP
CMD sed -i 's/#rc_sys="lxc"/g' /etc/rc.conf 
CMD echo 'rc_provide="loobback net"' >> /etc/rc.conf 
CMD sed -i 's/^#\(rc_logger="YES"\)$/\1/' /etc/rc.conf 
CMD sed -i 'tty/d' /etc/inittab 
CMD sed -i 's/hostname &opts/# hostname $opts/g' /etc/init.d/hostname 
CMD sed -i 's/mount -t tmpfs/# mount -t tmpfs/g' /lib/rc/sh/init.sh 
CMD sed -i 's/cgroup_add_service /# cgroup_add_service /g' /lib/rc/sh/openrc-run.sh 

##VIRTUAL GROUP, CREATE OPENRC-PARTS
CMD ["openrc-parts", "start"]
ENTRYPOINT ["openrc"]
CMD chkconfig openrc on

##VIRTUAL GROUP, CREATE WORKING DIRECTORY WEBCORE-PARTS
CMD mkdir /webcore-parts
WORKDIR /webcore-parts
COPY . /webcore-parts

##VIRTUAL GROUP, INSTALL WEBCORE DEPENDENCIES  
RUN apk add --no-cache --virtual openssh python python-dev py-pip build-base dumb-init ca-certificates npm
  
##VIRTUAL GROUP, INSTALL WEBCORE SERVICES
RUN apk add --no-cache --virtual lighttpd php5-common php5-iconv php5-json php5-gd php5-curl php5-xml php5-pgsql php5-imap php5-cgi fcgi 
RUN apk add --no-cache --virtual php5-pdo php5-pdo_pgsql php5-soap php5-xmlrpc php5-posix php5-mcrypt php5-gettext php5-ldap php5-ctype php5-dom 

##VIRTUAL GROUP, CONFIGURE WEBCORE
CMD sed -i '/^#.* include "mod_fastcgi.conf" /s/^#//' /etc/lighttpd/lighttpd.conf

CMD rc-service lighttpd start && rc-update add lighttpd default

##VIRTUAL GROUP, CREATE WEBCORE-PARTS
CMD ["webcore-parts", "start"]
ENTRYPOINT ["lighttpd"]
CMD chkconfig lighttpd on

CMD sed -i '/^#.* include "mod_fastcgi.conf@webcore-parts" /s/^#//' /etc/lighttpd/lighttpd.conf                

##VIRTUAL GROUP, CREATE WORKING DIRECTORY DATABASE-PARTS
CMD mkdir /database-parts
WORKDIR /database-parts
COPY . /database-parts

##UPDATE APK REPO LIST
RUN apk update

##VIRTUAL GROUP, INSTALL DATABASE DEPENDENCIES
RUN apk add --no-cache --virtual php5-pear pear install DB 

##VIRTUAL GROUP, INSTALL DATABASE MYSQL-CLIENT
RUN apk add --virtual mariadb-common mariadb-client mysql-client 

##VIRTUAL GROUP, CREATE DATABASE-PARTS 
CMD ["database-parts", "start"]
ENTRYPOINT ["mysql"]
CMD chkconfig mysql on

##VIRTUAL GROUP, CONFIGURE DATABASE-PARTS
CMD mysql_install_db --user=mysql
CMD mysqladmin -u root password 'passw0rd'


##VIRTUAL GROUP, WORKING DIRECTORY NPM-PARTS
CMD mkdir /npm-parts
WORKDIR /npm-parts
COPY . /npm-parts

##VIRTUAL GROUP, INSTALL DEPENDENCIES NPM
CMD npm install node.js
CMD npm install elasticache-client
CMD npm install prompt
CMD npm install aws-serverless-express

##AWS ELASTICACHE CONFIG
##CMD var Memcached = require('elasticache-client');
##CMD var prompt = require('prompt')
##prompt.start();
##prompt.get(new Memcached['Server Locations', 'config', 'options'], function (err, result) {
##  console.log('Command-line input received:');
##  console.log('  Server locations: ' + result.Server locations);
##  console.log('  config: ' + result.config);
##  console.log('  options: ' + result.options);
##CMD var memcached = new Memcached(Server locations, config, options); 
##});

##VIRTUAL GROUP, CREATE NPM-PARTS
CMD ["npm-parts", "start"]
ENTRYPOINT ["npm"]
CMD chkconfig npm on

##VIRTUAL GROUP, CREATE WORKING DIRECTORY ASTERISK-PARTS
CMD mkdir /asterisk-parts
WORKDIR /asterisk-parts
COPY . /asterisk-parts

##VIRTUAL GROUP, INSTALL ASTERISK
RUN apk add --no-cache --virtual asterisk asterisk-sample-config dahdi-linux-vserver asterisk-addons-mysql

##VIRTUAL GROUP, CREATE ASTERISK-PARTS
CMD ["asterisk-parts", "start"]
ENTRYPOINT ["asterisk-parts"]
CMD chkconfig asterisk-parts on

##VIRTUAL GROUP, CREATE WORKING DIRECTORY PBX-PARTS
CMD mkdir /pbx-parts
WORKDIR /pbx-parts
COPY . /pbx-parts

##VIRTUAL GROUP, INSTALL FREEPBX
CMD wget http://mirror.freepbx.org/modules/packages/freepbx/freepbx-13.0-latest.tgz /pbx-parts/freepbx-13.0-latest.tgz
CMD tar zxvf /pbx-parts/freepbx-13.0-latest.tgz && cd /pbx-parts/freepbx-13.0-latest

##VIRTUAL GROUP, ADD FREEPBX DB TO MYSQL
CMD mysqladmin create asterisk -p
CMD mysqladmin create asteriskcdrdb -p
CMD mysql -D asterisk -u root -p < SQL/newinstall.sql
CMD mysql -D asteriskcdrdb -u root -p < SQL/cdr_mysql_table.sql
CMD mysql -uroot -ppassw0rd GRANT ALL PRIVILEGES ON asterisk.* TO asteriskuser@localhost IDENTIFIED BY 'amp109'; exit
CMD mysql -uroot -ppassw0rd GRANT ALL PRIVILEGES ON asteriskcdrdb.* TO asteriskuser@localhost IDENTIFIED BY 'amp109'; exit

##VIRTUAL GROUP, ADD SED patch
RUN apk add --no-cache --virtual sed-patch

##VIRTUAL GROUP, INSTALL PERL FOR FPO
RUN apk add --no-cache --virtual perl

##VIRTUAL GROUP, CREATE PBX-PARTS
CMD ["pbx-parts", "start"]
ENTRYPOINT ["pbx-parts"]
CMD chkconfig pbx-parts on

##VIRTUAL GROUP, RUN INSTALLER
CMD install_amp --virtual

##FINAL VIRTUAL GROUP
##CMD ["pbx-parts", "start"]
##ENTRYPOINT ["pbx-parts"]

##CHANGE GROUPNAME & USERNAME 'lighttpd' TO 'asterisk'
CMD groupmod --new-name asterisk lighttpd
CMD usermod --new-name asterisk lighttpd

##ADJUST PERMISSIONS FOR FREEPBX
CMD chown -R asterisk:asterisk /var/log/lighttpd
CMD chown -R asterisk:asterisk /var/run/lighttpd*
CMD chown -R asterisk:asterisk /var/www/localhost/htdocs/freepbx
CMD systemctl start lighttpd

##APPLY PATCH FOR FREEPBX
CMD cd /var/lib/asterisk/bin
CMD patch -p0 < freepbx_engine.patch
CMD cd /var/www/localhost/htdocs/freepbx/admin/modules/framework/bin/
CMD patch -p0 freepbx_engine.patch



##DOWNLOAD & INSTALL AWS ELASTICACHE
##RUN /bin/sh wget https://elasticache-downloads.s3.amazonaws.com/ClusterClient/PHP-7.0/latest-64bit

##START PORTAL & SERVICES
CMD amportal start
CMD fwconsole start
CMD modprobe dahdi
CMD modprobe dahdi_dummy
CMD chkconfig amportal on
CMD chkconfig fwconsole on

##LOAD ON BOOT
CMD echo dahdi >> /etc/modules
CMD echo dahdi_dummy >> /etc/modules

##HOUSE KEEPING
CMD rm -rf /var/cache/apk/*

##ADD start.sh /root/
dumb-init openrc
dumb-init lighttpd
dumb-init npm
dumb-init mysql
dumb-init asterisk

##PORTAL START
CMD fwconsole start
