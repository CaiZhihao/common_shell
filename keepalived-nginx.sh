#!/bin/bash
# nginx+keepalived 高可用一键脚本for ubuntu 16.04

if [ $# -ne 4 ]; then
    echo "USAGE: $0 [MASTER|BACKUP] priority interface virtual_ipaddress"
    exit 0
fi

echo -e 'Installing nginx'
apt-get install nginx -y > /dev/null 2<&1

echo -e 'Installing keepalived'
apt-get install keepalived -y > /dev/null 2<&1

echo -e 'Configuring keepalived'
if [ ! -e /etc/keepalived ];then
    mkdir /etc/keepalived
fi
cat > /etc/keepalived/keepalived.conf <<EOF
! Configuration File for keepalived
global_defs {
    notification_email {
        chencheng199211@gmail.com
    }
    notification_email_from email
    smtp_server 127.0.0.1
    smtp_connect_timeout 30
    router_id master
}
vrrp_script chk_nginx {
    script "/etc/keepalived/check_nginx.sh"
    interval 2
    weight -5
    fall 3
    rise 2
}
vrrp_instance VI_1 {
    state $1
    interface $3
    virtual_router_id 51
    priority $2
    advert_int 2
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        $4
    }
    track_script {
       chk_nginx
    }
}
EOF

cat > /etc/keepalived/check_nginx.sh <<EOF
#!/bin/bash
# description:
# 定时查看nginx是否存在，如果不存在则启动nginx
# 如果启动失败，则停止keepalived
status=$(ps -C nginx --no-heading | wc -l)
if [ "${status}" = "0" ]; then
        service nginx start 
        sleep 2
        status2=$(ps -C nginx --no-heading | wc -l)
        if [ "${status2}" = "0"  ]; then
                /etc/init.d/keepalived stop
        fi
fi
EOF

echo -e "enable boot and starting"
service keepalived start
service nginx start
