#!/bin/bash
ORP="000"
ENV="development"
PORT0=8000
PORT1=8001
PORT2=8002
PORT3=8003

usage() {
    echo "Usage:"
    echo "    $0 [-o ORP] [-e ENV]"
    echo "Description:"
    echo "    ORP  第几个环境(orp{000-999})."
    echo "    ENV  development(开发环境) or testing(测试环境)."
    exit -1
}

while getopts ':o:e:' opt; do
    case $opt in
        o) ORP=`printf "%03d\n" "$OPTARG"`;;
        e) ENV="$OPTARG";;
        ?) usage;;
    esac
done

user=work
group=work
 
# create group if not exists
egrep "^$group" /etc/group >& /dev/null
if [ $? -ne 0 ]
then
    groupadd -g 1000 $group
fi
 
# create user if not exists
egrep "^$user" /etc/passwd >& /dev/null
if [ $? -ne 0 ]
then
    useradd -u 1000 -g 1000 $user

DIRNAME="orp"${ORP}
ORP_PATH="/home/work/orp"${ORP}

if [ -d $ORP_PATH ]; then
    echo "该环境已经存在"
    exit -1
else
    if [ $ORP -lt 0 -o $ORP -gt 999 ]; then
        echo "-o参数应该介于000-999"
        exit -1
    fi
    PORT0=$((${ORP} * 10 + 8000))
    PORT1=$((${ORP} * 10 + 8001))
    PORT2=$((${ORP} * 10 + 8002))
    PORT3=$((${ORP} * 10 + 8003))
    echo "开始构建环境"
    mkdir -p $ORP_PATH && \
    cd $ORP_PATH && \
    git clone https://github.com/gethinyan/docker.git && \
    cp -r ${ORP_PATH}/docker/configure/debug ${ORP_PATH}/docker/nginx ${ORP_PATH}/docker/configure/php . && \
    rm -rf ${ORP_PATH}/docker && \
    if [ "testing" = $ENV ]; then sed -i "s/development/testing/g" ${ORP_PATH}/nginx/conf/servers/work.conf; fi && \
    docker run -it \
        -p ${PORT0}:8080 \
        -p ${PORT1}:8081 \
        -p ${PORT2}:8082 \
        -p ${PORT3}:8083 \
        -v ${ORP_PATH}/debug:/home/work/orp/debug \
        -v ${ORP_PATH}/logs:/home/work/orp/logs \
        -v ${ORP_PATH}/static:/home/work/orp/static \
        -v ${ORP_PATH}/webroot:/home/work/orp/webroot \
        -v ${ORP_PATH}/nginx/conf:/home/work/orp/nginx/conf \
        -v ${ORP_PATH}/nginx/logs:/home/work/orp/nginx/logs \
        -v ${ORP_PATH}/php/etc:/home/work/orp/php/etc \
        -v ${ORP_PATH}/php/lib:/home/work/orp/php/lib \
        --name $DIRNAME \
        -d registry.cn-hangzhou.aliyuncs.com/xkd-docker-registry/xkd-docker-registry:v1.0-dev-2018-07-23 /bin/bash && \
    chown -R work:work $ORP_PATH && \
    docker exec $DIRNAME sh /home/work/orp/entrypoint.sh && \
    exit 0
fi

usage
