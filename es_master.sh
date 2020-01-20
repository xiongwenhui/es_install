#!/bin/bash
EsPath=/usr/local/elasticsearch
NodeName=master
JvmSize=15G
NodeMaster=true
NodeData=false

#安装jdk
#wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u141-b15/336fa29ff2bb4ef291e347e091f7f4a7/jdk-8u141-linux-x64.rpm"
#yum install  jdk-8u141-linux-x64.rpm -y
#echo 'export JAVA_HOME=/usr/java/jdk1.8.0_141' >> /etc/profile
#echo 'export CLASSPATH=.:$CLASSPTAH:$JAVA_HOME/lib' >> /etc/profile
#echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /etc/profile
#source /etc/profile
#java -version

#下载es
wget --no-check-certificate https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.5.1-linux-x86_64.tar.gz
tar -zxvf elasticsearch-7.5.1-linux-x86_64.tar.gz
mv elasticsearch-7.5.1 $EsPath
mkdir -p $EsPath/data
mkdir -p $EsPath/logs
mkdir -p $EsPath/plugins/ik
chmod 777 $EsPath/plugins/ik
chmod 777 $EsPath/data
chmod 777 $EsPath/logs
echo "下载es成功"

#建立用户
#chattr -i /etc/gshadow /etc/group /etc/shadow /etc/passwd
#useradd es
chown -R es:es $EsPath

#修改系统配置
#echo "vm.swappiness = 1" >> /etc/sysctl.conf
#echo "vm.max_map_count = 655360" >> /etc/sysctl.conf
#sysctl -p
#sysctl vm.swappiness
#sysctl vm.max_map_count

#echo -e "* soft memlock unlimited\n* hard memlock unlimited" >> /etc/security/limits.d/20-nproc.conf

#echo -e "* soft nofile 65536\n* hard nofile 65536\n* soft nproc 4096\n* hard nproc 4096" >> /etc/security/limits.conf
#ulimit -n

#echo "* soft nproc 4096" >> /etc/security/limits.d/20-nproc.conf

#修改权限文件
mv -f /home/es_install-master/elastic-certificates.p12 $EsPath/config/elastic-certificates.p12
chmod 777 $EsPath/config/elastic-certificates.p12

#修改es配置
mv -f /home/es_install-master/elasticsearch.yml $EsPath/config/elasticsearch.yml
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
wget --no-check-certificate https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.5.1/elasticsearch-analysis-ik-7.5.1.zip
mv elasticsearch-analysis-ik-7.5.1.zip $EsPath/plugins/
cd $EsPath/plugins/
yum -y install unzip
unzip -d $EsPath/plugins/ik/ elasticsearch-analysis-ik-7.5.1.zip
rm -rf elasticsearch-analysis-ik-7.5.1.zip

#安装repository-hdfs
mkdir $EsPath/plugins/repository-hdfs
cd $EsPath/plugins/repository-hdfs
wget --no-check-certificate https://artifacts.elastic.co/downloads/elasticsearch-plugins/repository-hdfs/repository-hdfs-7.5.1.zip
unzip repository-hdfs-7.5.1.zip

#开机启动
#mv /home/es_install-master/es /etc/init.d
#cd /etc/init.d
#chmod +x es
#chkconfig --add es

#启动es
#service es start
#echo "启动中，请等待30s"
#sleep 30s
#curl localhost:9200
