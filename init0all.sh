#!/bin/bash
ORG=$1
if [[ ! $2 == "" ]]; then MAIN_POJECT=$2; else MAIN_POJECT="grafana"; fi
directories=$(find .. -maxdepth 1 -type d)
ID=0
for dir in $directories; do ((ID++)); done

copy_nginx_conf() {
    HT_PASS=$(openssl rand -base64 20 | tr -d '\n')   > /dev/null
    htpasswd -b -c /server/$MAIN_POJECT/config/nginx/conf.d/$ORG-$SERVICE.htpasswd $ORG-$SERVICE $HT_PASS    > /dev/null
    INIT_CONF=$(cat /server/$MAIN_POJECT/config/nginx/conf.d/.conf_blank)   > /dev/null
    INIT_CONF=${INIT_CONF//localserv/$SERVICE-$ORG}   > /dev/null
    INIT_CONF=${INIT_CONF//pppp/$PORT}   > /dev/null
    echo "${INIT_CONF//service/$ORG-$SERVICE}" > /server/$MAIN_POJECT/config/nginx/conf.d/$ORG-$SERVICE.conf
}

copy_blank() {
    mkdir /server/$ORG/
    cp -a /server/blank-docker-prom-loki/config /server/$ORG/
    mkdir /server/$ORG/production/
}

make_usr_grp() {
    adduser --disabled-password --gecos "" $ORG
    echo "$ORG:$user_pass" | chpasswd
    usermod -u 10${TYPE}${ID} $ORG
    killall -u $ORG
    groupmod -g 10${TYPE}${ID} $ORG
    usermod -aG $ORG $ORG

    chown -R $ORG:$ORG /server/$ORG
}
if [ -d "/server/$ORG" ]; then 
    echo "Проект $ORG уже существует!"
else
    copy_blank
    TYPE=22
    INIT_ENV=$(cat /server/$ORG/config/.env_blank)   > /dev/null

    SERVICE=prometheus
    PORT=9090
    copy_nginx_conf
    INIT_ENV=${INIT_ENV//prom_pass/$HT_PASS}   > /dev/null

    SERVICE=loki
    PORT=3100
    copy_nginx_conf
    INIT_ENV=${INIT_ENV//loki_pass/$HT_PASS}   > /dev/null
    
    cd /server/timeweb/   > /dev/null
    bash /server/timeweb/subdom_make.sh $ORG-prometheus
    bash /server/timeweb/subdom_make.sh $ORG-loki

    INIT_ENV=${INIT_ENV//id/$ID}   > /dev/null
    INIT_ENV=${INIT_ENV//project/$ORG}   > /dev/null
    user_pass=$(openssl rand -base64 15 | tr -d '\n')   > /dev/null
    INIT_ENV=${INIT_ENV//user_pass/$user_pass}   > /dev/null
    echo "${INIT_ENV//mysql_root_pass/$mysql_root_pass}" > /server/$ORG/config/.env 
    DOCCOM_BLANK=$(cat /server/$ORG/config/docker-compose.yml_blank)   > /dev/null
    echo "${DOCCOM_BLANK//org/$ORG}" > /server/$ORG/config/docker-compose.yml
    rm /server/$ORG/config/docker-compose.yml_blank
    rm /server/$ORG/config/.env_blank
    make_usr_grp
fi
user_pass=''
HT_PASS=''

mkdir -p /server/$ORG/logs/loki 
mkdir -p /server/$ORG/production/loki

chmod 755 /server/$ORG -R
chmod 770 /server/$ORG
chmod 644 /server/$ORG/config/loki/loki-config.yaml

cd /server/$ORG/config && docker-compose up -d && docker-compose down
chown -R $ORG:$ORG /server/$ORG
chown -R 10001:10001 /server/$ORG/config/loki
chown -R 10001:10001 /server/$ORG/logs/loki
chown -R 10001:10001 /server/$ORG/production/loki
cd /server/$ORG/config && docker-compose up -d
docker restart nginx-$MAIN_POJECT