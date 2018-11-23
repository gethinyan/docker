#/bin/bash
chown -R work:work /home/work/ && \
service sshd start && \
su - work <<EOF
/home/work/orp/nginx/load_nginx.sh start
/home/work/orp/php/sbin/php-fpm -y /home/work/orp/php/etc/php-fpm.conf
EOF
