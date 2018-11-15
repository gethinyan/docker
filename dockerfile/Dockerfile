FROM centos:6
MAINTAINER gethin <gethin.yan@gmail.com>

RUN \
  yum install epel-release -y && \
  yum update -y && \
  yum install openssh-server openssh-clients -y && \
  yum install wget vim lsof net-tools -y

RUN \
  service sshd start && \
  groupadd -g 1000 work && \
  useradd work -u 1000 -g 1000 && \
  echo hicoffice | passwd --stdin work

RUN \
  yum install gcc gcc-c++ install pcre pcre-devel openssl openssl-devel zlib zlib-devel -y && \
  mkdir -p /home/work/orp /home/work/orp/nginx/logs /home/work/orp/static /home/work/orp/webroot /home/work/source && \
  cd /home/work/source && wget https://raw.githubusercontent.com/gethinyan/docker/master/dockerfile/nginx-1.14.0.tar.gz && \
  wget https://github.com/alibaba/nginx-http-concat/archive/1.2.2.tar.gz && \
  wget https://github.com/openresty/headers-more-nginx-module/archive/v0.33.tar.gz && \
  tar -zxvf 1.2.2.tar.gz && tar -zxvf v0.33.tar.gz && \
  tar -zxvf nginx-1.14.0.tar.gz && cd nginx-1.14.0 && \
  ./configure --prefix=/home/work/orp/nginx \
    --user=work \
    --group=work \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_v2_module \
    --with-http_gzip_static_module \
    --with-http_sub_module \
    --add-module=../nginx-http-concat-1.2.2 \
    --add-module=../headers-more-nginx-module-0.33 && \
  make && make install

RUN \
  yum install curl-devel libpng libpng-devel libjpeg gd gd-devel libxml2 libxml2-devel -y && \
  cd /home/work/source && wget https://raw.githubusercontent.com/gethinyan/docker/master/dockerfile/php-7.2.8.tar.gz && \
  tar -xvf php-7.2.8.tar.gz && cd php-7.2.8 && \
  ./configure --prefix=/home/work/orp/php \
    --enable-fpm \
    --with-fpm-user=work \
    --with-fpm-group=work \
    --with-curl \
    --with-openssl \
    --with-zlib \
    --with-gd \
    --with-jpeg-dir \
    --with-png-dir \
    --with-freetype-dir \
    --with-mhash \
    --enable-mbstring \
    --enable-bcmath \
    --enable-sockets \
    --enable-zip \
    --enable-mysqlnd \
    --with-mysqli=mysqlnd \
    --with-pdo-mysql=mysqlnd && \
  make && make install && \
  cp /home/work/orp/php/etc/php-fpm.conf.default /home/work/orp/php/etc/php-fpm.conf && \
  cp /home/work/orp/php/etc/php-fpm.d/www.conf.default /home/work/orp/php/etc/php-fpm.d/www.conf

RUN \
  cd /home/work/orp && \
  wget https://raw.githubusercontent.com/gethinyan/docker/master/dockerfile/entrypoint.sh && \
  chmod +x entrypoint.sh

RUN \
  cd /home/work/orp/nginx && \
  wget https://raw.githubusercontent.com/gethinyan/docker/master/dockerfile/load_nginx.sh && \
  chmod +x load_nginx.sh

VOLUME /home/work/orp/nginx/conf
VOLUME /home/work/orp/nginx/logs
VOLUME /home/work/orp/static
VOLUME /home/work/orp/webroot
VOLUME /home/work/orp/logs
VOLUME /home/work/orp/php/etc
VOLUME /home/work/orp/php/lib

RUN \
  rm -rf /home/work/source/* && \
  chown work:work /home/work -R

EXPOSE 8080
EXPOSE 8081
EXPOSE 8082
EXPOSE 8083

ENTRYPOINT ["/bin/bash"]