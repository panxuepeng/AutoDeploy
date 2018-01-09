#!/bin/bash

filename=`basename $0`
dirname=`dirname $0`
echo $dirname
cd $dirname

. options.conf

list_old_versions() {
    echo "已有版本列表:";
    ssh -i $ssh_pem root@$host "bash /data/AutoDeploy/server.sh list"
}

deploy() {
    version=$1

    if [ -z "$version" ]; then echo "请输入版本号，如 2.0.2"; exit 1; fi

    echo "即将开始上线..."
    sleep 2


    if [ ! -d "$project_dir" ]; then echo "project_dir 目录不存在，请查看配置文件修改"; exit 1; fi

    if [ ! -d "$export_dir" ]; then echo "export_dir 目录不存在，请查看配置文件修改"; exit 1; fi

    ### 定位到项目目录
    cd $project_dir
    git checkout master

    echo "即将开始导出文件..."
    sleep 3
    

    tarfile=master-$(git log --pretty=format:"%h" -1).tar.gz
    export_file=$export_dir/$tarfile

    # 删除之前可能存在的文件
    rm $export_file

    # 导出文件
    git archive --format tar.gz -o $export_file HEAD

    echo "即将开始上传..."
    sleep 3

    ### 上传压缩包到服务器
    scp -i $ssh_pem $export_dir/$tarfile $username@$host:/data/temp/

    echo "即将开始部署..."
    sleep 5

    ### 远程执行部署
    ssh -i $ssh_pem $username@$host "bash /data/AutoDeploy/server.sh deploy $version $tarfile"
}

online() {
    version=$1

    if [ -z "$version" ]; then echo "请输入版本号，如 2.0.2"; exit 1; fi

    ssh -i $ssh_pem $username@$host "bash /data/AutoDeploy/server.sh online $version"
}


case "$1" in
    'list')
        list_old_versions
    ;;
    'deploy')
        deploy $2
    ;;
    'online')
        online $2
    ;;
    *)
        echo ''
        echo "usage: bash $filename list (查看现有的版本列表)"
        echo "usage: bash $filename deploy \$version"
        echo "usage: bash $filename online \$version"

        list_old_versions
    ;;
esac

