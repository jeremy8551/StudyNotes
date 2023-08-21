#! /usr/bin/ksh

echo " "
echo " "
echo "*************************************************"
echo 开始FTP核心数据, 时间: `date +%Y-%m-%d_%T`

# 进入数据存放目录
_FILEDIR=$HOME/sjpt/data
cd $_FILEDIR
if [ $? -ne 0 ]; then 
    echo "进入目录${_FILEDIR}失败!" ;
    exit -1;
fi

#获取核心数据日期
_RQ=`$HOME/sjpt/bin/get_core_ywdate.sh`
_YY=`expr substr $_RQ 1 4`
_MM=`expr substr $_RQ 5 2`
_DD=`expr substr $_RQ 7 2`


# 如果核心数据日期为12月31号并且不年转，则建立损益结转后的目录13月31号
$HOME/sjpt/bin/get_core_nzbz.sh
if [ $? -ne 0 -a ${_MM} -eq 12 -a ${_DD} -eq 31 ]; then 

ftp -n -v <<!
open `sed -n '1'p $HOME/sjpt/bin/ftp.ini`
user `sed -n '2'p $HOME/sjpt/bin/ftp.ini`
ascii
prompt
cd ./CORE
cd  ./${_YY}1231
get NZBZ.del
close
bye
!

# 如果年转标志文件存在，则建立年转后数据目录 yyyy1331
if [ -f $_FILEDIR/NZBZ.del ]; then
    rm -f $_FILEDIR/NZBZ.del
    _RQ=${_YY}1331
fi

fi

# 如果核心年转并且当前核心数据日期为12月30号，则传送年转标志文件NZBZ.del到数据平台
$HOME/sjpt/bin/get_core_nzbz.sh
if [ $? -eq 0 -a ${_MM} -eq 12 -a ${_DD} -eq 30 ]; then 
    echo "" > $_FILEDIR/NZBZ.del
    _RQ=${_YY}1231
fi

echo 数据日期: $_RQ > SUCCESS
ls -l >> SUCCESS

# 把数据FTP到数据平台服务器
echo 保存所有*.del 文本到目录 /CORE/$_RQ 
ftp -n -v <<!
open `sed -n '1'p $HOME/sjpt/bin/ftp.ini`
user `sed -n '2'p $HOME/sjpt/bin/ftp.ini`
ascii
cd ./CORE
rmdir $_RQ
mkdir $_RQ
cd  ./$_RQ
lcd $HOME/sjpt/data
prompt
delete SUCCESS
mput *.del

ascii
cd ..
cd ./$_RQ
put SUCCESS
close
bye
!
_rest=$?
if [ $_rest -ne 0 ]; then
    echo 传输文本发生错误, 返回码: $_rest
    exit 10
fi

echo 采集完毕, 时间: `date +%Y-%m-%d_%T` 

exit 0
