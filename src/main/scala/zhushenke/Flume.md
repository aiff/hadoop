Flume学习笔记
- 软件下载配置  
```
[hadoop@hadoop soft]# wget http://archive.cloudera.com/cdh5/cdh/5/flume-ng-1.6.0-cdh5.7.0.tar.gz
[hadoop@hadoop soft]# tar -zxvf flume-ng-1.6.0-cdh5.7.0.tar.gz
[hadoop@hadoop soft]# mv flume-ng-1.6.0-cdh5.7.0.tar.gz flume
[hadoop@hadoop soft]# mv flume/ ../app
[hadoop@hadoop soft]# chmod 755 ../app/flume -R
[hadoop@hadoop soft]# vi ~/.bash_profile
export FLUME_HOME=/hadoop/app/flume
export PATH=$PATH:$FLUME_HOME/bin
[hadoop@hadoop soft]# source ~/.bash_profile
```
- 软件使用测试  
```
#logger模式
[hadoop@hadoop soft]# mkdir /hadoop/script/flume
[hadoop@hadoop soft]# chmod 755 /hadoop/script -R && cd /hadoop/script/flume
[hadoop@hadoop flume]$ vi logger.conf
#定义 sources,sinks,channels的名称
a1.sources = s1
a1.sinks = k1
a1.channels = c1
#定义 sources 的属性
a1.sources.s1.type = netcat
a1.sources.s1.bind = 0.0.0.0
a1.sources.s1.port = 44444
#定义 sinks 的属性
a1.sinks.k1.type = logger
#定义 channels 的属性
a1.channels.c1.type = memory
#对 channel 的绑定
a1.sources.s1.channels = c1
a1.sinks.k1.channel = c1
#开启服务
[hadoop@hadoop flume]$ flume-ng agent --name a1 --conf $FLUME_HOME/conf \
--conf-file /hadoop/script/flume/logger.conf \
-Dflume.root.logger=INFO,console \
-Dflume.monitorint.type=http \
-Dflume.monitoring.port=34343
#telnet sources定义的端口,输入信息后在开启服务的窗口有内容返回即是成功
[hadoop@hadoop flume]$ telnet localhost 44444
```
![](../..//resources/image/logger.jpg) 
```   
#exec模式:exec-memory-hdfs
[hadoop@hadoop flume]$ vi exec-memory-hdfs.conf
#定义 sources,sinks,channels的名称
a1.sources = s1
a1.sinks = k1
a1.channels = c1
#定义 sources 的属性,使用 exec 方式
a1.sources.s1.type = exec
a1.sources.s1.command = tail -F /hadoop/other/exec-memory-hdfs.log
#定义 channels 的属性
a1.channels.c1.type = memory
a1.channels.c1.capacity = 10000
a1.channels.c1.transactionCapacity = 10000
#定义 sinks 的属性,传输文件到 hdfs 中,并更改文件滚动参数
a1.sinks.k1.type = hdfs
a1.sinks.k1.hdfs.path = hdfs://hadoop:9000/data/flume
a1.sinks.k1.hdfs.batchSize = 10000
a1.sinks.k1.hdfs.fileType = DataStream
a1.sinks.k1.hdfs.writeFormat = Text
a1.sinks.k1.hdfs.rollCount = 0
a1.sinks.k1.hdfs.rollSize = 10240000
a1.sinks.k1.hdfs.rollInterval = 0
a1.sinks.k1.hdfs.minBlockReplicas=1
a1.sinks.k1.hdfs.idleTimeout=0
#对 channel 的绑定
a1.sources.s1.channels = c1
a1.sinks.k1.channel = c1
#开启服务
[hadoop@hadoop flume]$ flume-ng agent --name a1 --conf $FLUME_HOME/conf \
--conf-file /hadoop/script/flume/exec-memory-hdfs.conf \
-Dflume.root.logger=INFO,console \
-Dflume.monitorint.type=http \
-Dflume.monitoring.port=34343
#批量插入数据,可以执行多次,以产生大量数据
[hadoop@hadoop flume]$ for i in $(seq 1 1000);do echo "Hello,Flume!" >> /hadoop/other/exec-memory-hdfs.log;done
#查看文件内容是否进入 hdfs 中
[hadoop@hadoop flume]$ hdfs -ls /data/flume
Found 1 items
-rw-r--r--   1 hadoop supergroup      90753 2018-07-31 05:09 /data/flume/FlumeData.1532984979314.tmp   
[hadoop@hadoop flume]$ hadoop fs -text /data/flume/FlumeData.1532984979314.tmp
Hello,Flume.
Hello,Flume.
Hello,Flume.
Hello,Flume.
Hello,Flume.
#查看文件在没有超过 blocksize 的情况下是否只有一个
```
![](../../resources/image/exec-memory-hdfs.jpg)