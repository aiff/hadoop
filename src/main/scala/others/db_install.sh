#!/bin/bash
export PATH=$PATH

###set firewalld&selinux
os=`cat /etc/redhat-release|awk '{print $4}'|awk -F'.' '{print $1}'`
if [ ${os} == "7" ];then
	systemctl disable firewalld && systemctl stop firewalld
        systemctl disable abrt-ccpp
        systemctl disable abrtd
        systemctl disable atd
        systemctl disable auditd
        systemctl disable cpuspeed
        systemctl disable cups
        systemctl disable dnsmasq
        systemctl disable firstboot
        systemctl disable lvm2-monitor
        systemctl disable netconsole
        systemctl disable netfs
        systemctl disable ntpd
        systemctl disable ntpdate
        systemctl disable portreserve
        systemctl disable postfix
        systemctl disable rdisc
        systemctl disable restorecond
        systemctl disable saslauthd
        systemctl disable wdaemon
        systemctl disable wpa_supplicant
        systemctl disable NetworkManager
        systemctl disable blk-availability
        systemctl disable cpuspeed
        systemctl disable lvm2-monitor
        systemctl disable restorecond
        systemctl disable netconsole
	if [ `getenforce` == "Enforcing" ];then
		setenforce 0
		sed -i "s!SELINUX=enforcing!SELINUX=disabled!g" /etc/selinux/config
	elif [ `getenforce` == "Permissive" ];then
		sed -i "s!SELINUX=enforcing!SELINUX=disabled!g" /etc/selinux/config
	else
		continue
	fi
else
	chkconfig iptables off && chkconfig ip6tables off && service iptables stop && service ip6tables stop
        chkconfig abrt-ccpp off
        chkconfig abrtd off
        chkconfig atd off
        chkconfig auditd off
        chkconfig cpuspeed off
        chkconfig cups off
        chkconfig dnsmasq off
        chkconfig firstboot off
        chkconfig lvm2-monitor off
        chkconfig netconsole off
        chkconfig netfs off
        chkconfig ntpd off
        chkconfig ntpdate off
        chkconfig portreserve off
        chkconfig postfix off
        chkconfig rdisc off
        chkconfig restorecond off
        chkconfig saslauthd off
        chkconfig wdaemon off
        chkconfig wpa_supplicant off
        chkconfig NetworkManager off
        chkconfig blk-availability off
        chkconfig cpuspeed off
        chkconfig lvm2-monitor off
        chkconfig restorecond off
        chkconfig netconsole off
	if [ `getenforce` == "Enforcing" ];then
                setenforce 0
                sed -i "s!SELINUX=enforcing!SELINUX=disabled!g" /etc/selinux/config
        elif [ `getenforce` == "Permissive" ];then
                sed -i "s!SELINUX=enforcing!SELINUX=disabled!g" /etc/selinux/config
        else
                continue
        fi
fi

###set the ip in hosts
hostname=`hostname`
ip=`ip a|grep 'inet '|grep -v '127.0.0.1'|awk '{print $2}'|awk -F '/' '{print $1}'`
for i in ${ip}
do
	a=`grep "${i}" /etc/hosts`
	if [ ! -n "${a}" ];then
		echo "${i} ${hostname}" >> /etc/hosts
	else
		break
	fi
done

###create group&user
ora_user=oracle
ora_group=('oinstall' 'dba' 'oper')
for i in ${ora_group[@]}
do
	a=`grep '${i}' /etc/group`
	if [ ! -n ${a} ];then
		groupdel ${i} && groupadd ${i}
	else
		groupadd ${i}
	fi
done
a=`grep 'oracle' /etc/passwd`
if [ ! -n ${a} ];then
	userdel -r ${ora_user} && useradd -u 501 -g ${ora_group[0]} -G ${ora_group[1]},${ora_group[2]} ${ora_user}
else
	useradd -u 501 -g ${ora_group[0]} -G ${ora_group[1]},${ora_group[2]} ${ora_user}
fi
echo "wincenter" | passwd --stdin ${ora_user}
###create directory and grant priv
count=0
while [ $count -lt 3 ]
do
	read -p "Please input the ORACLE_SID(e.g:orcl):" S1
	read -p "Please input the ORACLE_SID again(e.g:orcl):" S2
	if [ "${S1}" == "${S2}" ];then
		export ORACLE_SID=${S1}
		break
	else
		echo "You input ORACLE_SID not same."
		count=$[${count}+1]
	fi
done
count=0
while [ $count -lt 3 ]
do
        read -p "Please input the ORACLE_BASE(e.g:/oracle/app):" S1
        read -p "Please input the ORACLE_BASE again(e.g:/oracle/app):" S2
        if [ "${S1}" == "${S2}" ];then
                export ORACLE_BASE=${S1}
                break
        else
                echo "You input ORACLE_BASE not same."
                count=$[${count}+1]
        fi
done
count=0
while [ $count -lt 3 ]
do
        read -p "Please input the ORACLE_HOME(e.g:/oracle/app/db):" S1
        read -p "Please input the ORACLE_HOME again(e.g:/oracle/app/db):" S2
        if [ "${S1}" == "${S2}" ];then
                export ORACLE_HOME=${S1}
                break
        else
                echo "You input ORACLE_HOME not same."
                count=$[${count}+1]
        fi
done
if [ ! -d ${ORACLE_HOME} ];then
	mkdir -p ${ORACLE_HOME}
else
	continue
fi
if [ ! -d ${ORACLE_BASE}/data ];then
	mkdir -p ${ORACLE_BASE}/data
else
	continue
fi
if [ ! -d ${ORACLE_BASE}/recovery ];then
	mkdir -p ${ORACLE_BASE}/recovery
else
	continue
fi
ora_dir=`echo ${ORACLE_HOME}|awk -F '/' '{print $2}'`
last_dir=`echo ${ORACLE_HOME}|awk -F '/' '{print $NF}'`

###install require packages
yum -y install elfutils-libelf-devel binutils compat-libcap1 compat-libstdc++-33 gcc gcc-c++ glibc glibc-devel libaio libaio-devel libgcc libstdc++ libstdc++-devel libXi libXtst make sysstat unixODBC unixODBC-devel zip unzip tree

###set the sysctl,limits and profile
a=`grep 'fs.aio-max-nr' /etc/sysctl.conf`
if [ ! -n "${a}" ];then
cat << EOF >> /etc/sysctl.conf
fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmall = 2097152
kernel.shmmax = 4294967295
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
EOF
else
	continue
fi
a=`grep 'oracle' /etc/security/limits.conf`
if [ ! -n "${a}" ];then
cat << EOF >> /etc/security/limits.conf
oracle soft nproc 2047
oracle hard nproc 16384
oracle soft nofile 1024
oracle hard nofile 65536
oracle soft stack 10240
EOF
else
	continue
fi
a=`grep 'ORACLE_SID' /home/${ora_user}/.bash_profile`
if [ ! -n "${a}" ];then
cat << EOF >> /home/${ora_user}/.bash_profile
export ORACLE_SID=${ORACLE_SID}
export ORACLE_BASE=${ORACLE_BASE}
export ORACLE_HOME=\$ORACLE_BASE/${last_dir}
export PATH=\$PATH:\$ORACLE_HOME/bin
EOF
else
	continue
fi
a=`grep 'oracle' /etc/profile`
if [ ! -n "${a}" ];then
cat << EOF >> /etc/profile
if [ \$USER = "oracle" ];then
    if [ \$SHELL = "/bin/ksh" ];then
        ulimit -p 16384
        ulimit -n 65536
    else
        ulimit -u 16384 -n 65536
    fi
else
	continue
fi
EOF
else
    continue
fi
a=`grep 'pam_limits.so' /etc/pam.d/login`
if [ ! -n "${a}" ];then
cat << EOF >> /etc/pam.d/login
session   required    /lib/security/pam_limits.so
session   required    pam_limits.so
EOF
else
    continue
fi
sysctl -p && source /home/${ora_user}/.bash_profile

###unzip the install package and set response file
count=0
while [ $count -lt 3 ]
do
	read -p "Please input the zip file location(e.g:/oracle/db.zip):" zfile
	if [ ! -f ${zfile} ];then
		echo "You input location not found zip file."
		count=$[${count}+1]
	else
		export zfile=${zfile}
		break
	fi
done
unzip ${zfile} -d /${ora_dir} && chown -R ${ora_user}:${ora_group[0]}  /${ora_dir} && chmod -R 775 /${ora_dir}

free_m=`free -m | grep 'Mem:'|awk '{print $2}'`
db_response_file=`find / -type f -name db_install.rsp`
data_dir=${ORACLE_BASE}/data
recovery_dir=${ORACLE_BASE}/recovery
cd `find / -type f -name db_install.rsp | sed -n 's:/[^/]*$::p'` && cd ../
install_dir=`pwd`
sed -i "s!oracle.install.option=!oracle.install.option=INSTALL_DB_SWONLY!g" ${db_response_file}
sed -i "s!ORACLE_HOSTNAME=!ORACLE_HOSTNAME=${hostname}!g" ${db_response_file}
sed -i "s!UNIX_GROUP_NAME=!UNIX_GROUP_NAME=${ora_group[0]}!g" ${db_response_file}
sed -i "s!INVENTORY_LOCATION=!INVENTORY_LOCATION=${ORACLE_BASE}/oraInventory!g" ${db_response_file}
sed -i "s!SELECTED_LANGUAGES=en!SELECTED_LANGUAGES=en,zh_CN!g" ${db_response_file}
sed -i "s!ORACLE_HOME=!ORACLE_HOME=${ORACLE_HOME}!g" ${db_response_file}
sed -i "s!ORACLE_BASE=!ORACLE_BASE=${ORACLE_BASE}!g" ${db_response_file}
sed -i "s!oracle.install.db.InstallEdition=!oracle.install.db.InstallEdition=EE!g" ${db_response_file}
sed -i "s!oracle.install.db.DBA_GROUP=!oracle.install.db.DBA_GROUP=${ora_group[1]}!g" ${db_response_file}
sed -i "s!oracle.install.db.OPER_GROUP=!oracle.install.db.OPER_GROUP=${ora_group[2]}!g" ${db_response_file}
sed -i "s!oracle.install.db.config.starterdb.type=!oracle.install.db.config.starterdb.type=GENERAL_PURPOSE!g" ${db_response_file}
sed -i "s!oracle.install.db.config.starterdb.globalDBName=!oracle.install.db.config.starterdb.globalDBName=${ORACLE_SID}!g" ${db_response_file}
sed -i "s!oracle.install.db.config.starterdb.SID=!oracle.install.db.config.starterdb.SID=${ORACLE_SID}!g" ${db_response_file}
sed -i "s!oracle.install.db.config.starterdb.characterSet=AL32UTF8!oracle.install.db.config.starterdb.characterSet=ZHS16GBK!g" ${db_response_file}
sed -i "s!oracle.install.db.config.starterdb.memoryLimit=!oracle.install.db.config.starterdb.memoryLimit=$[free_m*8/10]!g" ${db_response_file}
sed -i "s!oracle.install.db.config.starterdb.password.ALL=!oracle.install.db.config.starterdb.password.ALL=wincenter!g" ${db_response_file}
sed -i "s!oracle.install.db.config.starterdb.storageType=!oracle.install.db.config.starterdb.storageType=FILE_SYSTEM_STORAGE!g" ${db_response_file}
sed -i "s!oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=!oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=${data_dir}!g" ${db_response_file}
sed -i "s!oracle.install.db.config.starterdb.fileSystemStorage.recoveryLocation=!oracle.install.db.config.starterdb.fileSystemStorage.recoveryLocation=${recovery_dir}!g" ${db_response_file}
sed -i "s!oracle.installer.autoupdates.option=!oracle.installer.autoupdates.option=SKIP_UPDATES!g" ${db_response_file}
sed -i "s!SECURITY_UPDATES=!SECURITY_UPDATES=true!g" ${db_response_file}
su - oracle -c "${install_dir}/runInstaller -silent -ignoreDiskWarning -ignoreSysPrereqs -ignorePrereq -responseFile ${db_response_file}"