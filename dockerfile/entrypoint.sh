#/bin/bash
su - work <<EOF
/home/work/orp/nginx/load_nginx.sh start
/home/work/orp/php/sbin/php-fpm -y /home/work/orp/php/etc/php-fpm.conf
EOF