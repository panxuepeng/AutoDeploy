#!/bin/bash

datetime=$1
version=$2

#datetime="20170922153012"
#version="2.0.1"

tarfile="${datetime}.tar.gz"
echo $tarfile $version

if [ -d /data/devs/$version ]; then echo "目录 $version 已存在"; exit 1; fi

# 创建临时目录
mkdir /data/devs/temp

# 将源码解压到临时目录
tar xf /data/temp/$tarfile -C /data/devs/temp

# 移动本次上线代码到新版本号目录
mv /data/devs/temp/${datetime} /data/devs/$version

# 删除临时目录
rm -Rf /data/devs/temp

echo $version > /data/devs/$version/public/version.txt

# copy vendor .env
cp -R /data/devs/vendor /data/devs/$version/
cp /data/devs/env.default /data/devs/$version/.env

ln -s /data/devs/storage /data/devs/$version/storage

# 设置内部缓存目录权限
chmod -R 777 /data/devs/$version/bootstrap/cache

# dev1.aiztou.com 测试站会直接更新
# dev.aiztou.com 在此时不更新
# dev1 测试OK之后再更新 dev，以避免dev异常影响其他同学的使用
rm /data/wwwroot/dev1.com
ln -s /data/devs/$version /data/wwwroot/dev1.com

echo "OK"
