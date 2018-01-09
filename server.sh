#!/bin/bash


list_old_versions() {
    for key in `ls /data/devs/`;do
        echo $key;
    done
}

online() {
    version=$1

    rm -f /data/wwwroot/dev.com
    ln -s /data/devs/$version /data/wwwroot/dev.com
}

deploy() {
    version=$1
    tarfile=$2

    echo $tarfile $version

    if [ -d /data/devs/$version ]; then echo "目录 $version 已存在"; exit 1; fi

    # 将源码解压到指定版本目录
    mkdir /data/devs/$version
    tar xf /data/temp/$tarfile -C /data/devs/$version

    # dev1.com 测试站会直接更新
    # dev.com 在此时不更新
    # dev1 测试OK之后再更新 dev，以避免dev异常影响其他同学的使用
    rm /data/wwwroot/dev1.com
    
    if [ -d /data/devs/$version/public ]; then
        ln -s /data/devs/$version/public /data/wwwroot/dev1.com
    else
        ln -s /data/devs/$version /data/wwwroot/dev1.com
    fi
    

    echo "OK"
}

case "$1" in
    'list')
        list_old_versions
    ;;
    'deploy')
        deploy $2 $3
    ;;
    'online')
        online $2
    ;;
    *)
        list_old_versions
    ;;
esac
