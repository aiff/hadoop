#!/bin/bash
export PATH=$PATH

PASSWORD="wincenter"
ORACLE_SID=`su - oracle -c 'source ~/.bash_profile && echo $ORACLE_SID'`
ORACLE_BASE=`su - oracle -c 'source ~/.bash_profile && echo $ORACLE_BASE'`
ORACLE_HOME=`su - oracle -c 'source ~/.bash_profile && echo $ORACLE_HOME'`

temp=`ls ${ORACLE_BASE}|grep 'data'`
if [ ! -n ${temp} ];then
        mkdir ${ORACLE_BASE}/data
        export DATAFILE=${ORACLE_BASE}/data
else
        export DATAFILE=${ORACLE_BASE}/data
fi
temp=`ls ${ORACLE_BASE}|grep 'area'`
if [ ! -n ${temp} ];then
        mkdir ${ORACLE_BASE}/flash_recovery_area
        export RECOVERY=${ORACLE_BASE}/flash_recovery_area
else
        export RECOVERY=${ORACLE_BASE}/flash_recovery_area
fi
NETCA=`find / -type f -name netca.rsp`
sed -i "s!INSTALL_TYPE=""typical""!INSTALL_TYPE=""custom""!g" ${NETCA}
MEM=`free -m|grep 'Mem:'|awk '{print $2}'`
TOTAL=$[MEM*8/10]

###set listener&tnsnames
su - oracle << EOF
source ~/.bash_profile
${ORACLE_HOME}/bin/netca -silent -responsefile ${NETCA}
dbca -silent -createDatabase -templateName General_Purpose.dbc -gdbname ${ORACLE_SID} -sid ${ORACLE_SID} -sysPassword ${PASSWORD} -systemPassword ${PASSWORD} -responseFile NO_VALUE -datafileDestination ${DATAFILE} -redoLogFileSize 1000 -recoveryAreaDestination ${RECOVERY} -storageType FS -characterSet ZHS16GBK -nationalCharacterSet AL16UTF16 -sampleSchema false -memoryPercentage 80 -totalMemory $TOTAL -databaseType OLTP -emConfiguration NONE
EOF