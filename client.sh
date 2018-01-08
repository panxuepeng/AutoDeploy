#!/bin/bash

filename=`basename $0`
dirname=`dirname $0`
echo $dirname
cd $dirname

. options.conf

list_old_versions() {
    echo "\n已有版本列表:";
    ssh -i $ssh_pem root@$host "/usr/local/php/bin/php /data/autodeploy/server-list.php"
}

deploy_dev() {
    version=$1

    if [ -z "$version" ]; then echo "请输入版本号，如 2.0.2"; exit 1; fi

    echo "即将开始上线..."
    sleep 2

    datetime=$(date +"%Y%m%d%H%M%S")
    
    if [ ! -d "$baseDir" ]; then echo "baseDir 目录不存在，请查看配置文件修改"; exit 1; fi

    ### 必须定位到当前目录
    cd $baseDir

    echo "即将开始导出文件..."
    sleep 3

    exportDir="$baseDir/${datetime}"

    svn export $devSvnUrl -q $exportDir

    if [ ! -d "$exportDir" ]; then echo "代码导出异常，请检查代码仓库是否可以正常导出"; exit 1; fi

    tarfile=${datetime}.tar.gz

    echo "即将开始打包文件 $tarfile ..."
    sleep 3

    ### 压缩代码目录，并排除部分目录
    tar -cf ${datetime}.tar.gz  --exclude=storage --exclude=tests $datetime


    echo "即将开始上传..."
    sleep 3

    ### 上传压缩包到服务器
    scp -i $ssh_pem $tarfile root@$host:/data/temp/

    echo "即将开始部署..."
    sleep 5

    ### 远程执行部署
    ssh -i $ssh_pem root@$_host "sh /data/autodeploy/server.sh $datetime $version"
}

online() {
    version=$1

    if [ -z "$version" ]; then echo "请输入版本号，如 2.0.2"; exit 1; fi

    ssh -i $ssh_pem root@$host "sh /data/autodeploy/server-online.sh $version"
}



case "$1" in
    'list')
        list_old_versions
    ;;
    'deploy')
        deploy_dev $2
    ;;
    'online')
        online $2
    ;;
    *)
        echo ''
        echo "usage: sh $filename list (查看现有的版本列表)"
        echo "usage: sh $filename deploy \$version"
        echo "usage: sh $filename online \$version"

        list_old_versions
    ;;
esac

