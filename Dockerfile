FROM centos:7
MAINTAINER Nick Jiang <udiabon@163.com>

RUN echo "ip_resolve=4" >> /etc/yum.conf

ADD ./nginx.repo /etc/yum.repos.d/nginx.repo

RUN yum -y install wget

RUN wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN wget http://rpms.remirepo.net/enterprise/remi-release-7.rpm
RUN rpm -Uvh remi-release-7.rpm epel-release-latest-7.noarch.rpm

#RUN rm -f /etc/yum.repos.d/remi.repo
#RUN rm -f /etc/yum.repos.d/remi-safe.repo

#ADD ./remi-safe.repo /etc/yum.repos.d/remi-safe.repo
#ADD ./remi.repo /etc/yum.repos.d/remi.repo

RUN curl --silent --location https://rpm.nodesource.com/setup_4.x | bash -

RUN yum -y install nginx \
        telnet \
        bind-utils \
        lsof \
        git \
        python \
        python-setuptools \
        php-common \
        php-cli \
        php-fpm \
        php-pecl-xdebug \
        php-gd \
        php-mbstring \
        php-mysql \
        php-odbc \
        php-pdo \
        php-soap \
        php-xml

#RUN sed -i -e 's/zend_extension=/;zend_extension=/' /etc/php.d/*xdebug.ini
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN composer config -g repo.packagist composer https://packagist.phpcomposer.com
RUN composer global require "fxp/composer-asset-plugin:~1.1.0"
RUN composer global require "laravel/installer"
RUN echo 'export PATH=$HOME/.composer/vendor/bin:$PATH' >> /root/.bashrc

RUN easy_install supervisor

RUN yum -y install nodejs \
        gcc-c++ \
        make

RUN /usr/bin/npm install -g cnpm --registry=https://registry.npm.taobao.org

#Upgrade to the latest version
RUN /usr/bin/cnpm install -g npm
RUN /usr/bin/cnpm install -g typescript

#Install OpenResty
RUN yum -y install yum-utils
RUN yum -y install perl
ADD openresty.repo /etc/yum.repos.d/openresty.repo
RUN yumdownloader -y openresty openresty-openssl openresty-resty && rpm -ivh --nodeps openresty* && rm -f openresty*

RUN mkdir -p /etc/nginx/{sites-available,sites-enabled}
RUN mkdir -p /data/projects
RUN chmod 777 /data && chmod 777 /data/projects
RUN sed -i -e 's/\sinclude\s\/etc\/nginx\/conf\.d\/\*\.conf;/\tinclude \/etc\/nginx\/conf.d\/*.conf;\n\tinclude \/etc\/nginx\/sites-enabled\/*;/' /etc/nginx/nginx.conf
RUN sed -i -e 's/\suser\snginx;/user root;/' /etc/nginx/nginx.conf
RUN echo 'daemon off;' >> /etc/nginx/nginx.conf
RUN mv /etc/localtime /etc/localtime.bak
RUN ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN sed -i -e 's/;date\.timezone =/date.timezone = Asia\/Shanghai/g' /etc/php.ini

VOLUME ["/data/projects", "/etc/nginx", "/etc/php-fpm.d", "/var/log/nginx", "/var/log/php-fpm", "/var/lib/php/session", "/root/.composer", "/root/.npm"]

EXPOSE 80
EXPOSE 443

ADD ./supervisord.conf /etc/supervisord.conf
ADD ./start.sh /start.sh
RUN chmod 755 /start.sh

CMD ["/bin/bash", "/start.sh"]
