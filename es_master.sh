#!/bin/bash
EsPath=/usr/local/elasticsearch
NodeName=master
JvmSize=20G
NodeMaster=true
NodeData=false

#下载es
wget --no-check-certificate https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.6.1.tar.gz
tar -zxvf elasticsearch-6.6.1.tar.gz
mv elasticsearch-6.6.1 $EsPath
mkdir -p $EsPath/data
mkdir -p $EsPath/logs
mkdir -p $EsPath/plugins/ik
chmod 777 $EsPath/plugins/ik
chmod 777 $EsPath/data
chmod 777 $EsPath/logs
echo "下载es成功"

#建立用户
useradd es
chown -R es:es $EsPath

#修改系统配置
echo "vm.swappiness = 1" >> /etc/sysctl.conf
echo "vm.max_map_count = 655360" >> /etc/sysctl.conf
sysctl -p
sysctl vm.swappiness
sysctl vm.max_map_count

#echo -e "* soft nofile 65536\n* hard nofile 65536\n* soft nproc 4096\n* hard nproc 4096" >> /etc/security/limits.conf
#ulimit -n

#echo "* soft nproc 4096" >> /etc/security/limits.d/20-nproc.conf


#修改es配置
mv -f /home/elasticsearch.yml $EsPath/config/elasticsearch.yml
ip=$(/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v 172.17.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:")
node=$NodeName-${ip##*.}
sed -i "s/network.publish_host:/network.publish_host: $ip/g" $EsPath/config/elasticsearch.yml
sed -i "s/node.name:/node.name: $node/g" $EsPath/config/elasticsearch.yml
sed -i "s/node.master:/node.master: $NodeMaster/g" $EsPath/config/elasticsearch.yml
sed -i "s/node.data:/node.data: $NodeData/g" $EsPath/config/elasticsearch.yml

sed -i "s/-Xms1g/-Xms$JvmSize/g" $EsPath/config/jvm.options
sed -i "s/-Xmx1g/-Xmx$JvmSize/g" $EsPath/config/jvm.options
echo "修改配置成功"

#配置中文分词
wget --no-check-certificate https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v6.6.1/elasticsearch-analysis-ik-6.6.1.zip
mv elasticsearch-analysis-ik-6.6.1.zip $EsPath/plugins/
cd $EsPath/plugins/
yum -y install unzip
unzip -d $EsPath/plugins/ik/ elasticsearch-analysis-ik-6.6.1.zip
rm -rf elasticsearch-analysis-ik-6.6.1.zip

#启动es
su - es <<EOF
$EsPath/bin/elasticsearch -d;
exit;
EOF
echo "启动中，请等待60s"
sleep 60s
curl localhost:9200
