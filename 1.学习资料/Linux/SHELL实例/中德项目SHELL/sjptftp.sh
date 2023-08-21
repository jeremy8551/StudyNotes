#! /usr/bin/ksh

echo " "
echo " "
echo "*************************************************"
echo ��ʼFTP��������, ʱ��: `date +%Y-%m-%d_%T`

# �������ݴ��Ŀ¼
_FILEDIR=$HOME/sjpt/data
cd $_FILEDIR
if [ $? -ne 0 ]; then 
    echo "����Ŀ¼${_FILEDIR}ʧ��!" ;
    exit -1;
fi

#��ȡ������������
_RQ=`$HOME/sjpt/bin/get_core_ywdate.sh`
_YY=`expr substr $_RQ 1 4`
_MM=`expr substr $_RQ 5 2`
_DD=`expr substr $_RQ 7 2`


# ���������������Ϊ12��31�Ų��Ҳ���ת�����������ת���Ŀ¼13��31��
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

# �����ת��־�ļ����ڣ�������ת������Ŀ¼ yyyy1331
if [ -f $_FILEDIR/NZBZ.del ]; then
    rm -f $_FILEDIR/NZBZ.del
    _RQ=${_YY}1331
fi

fi

# ���������ת���ҵ�ǰ������������Ϊ12��30�ţ�������ת��־�ļ�NZBZ.del������ƽ̨
$HOME/sjpt/bin/get_core_nzbz.sh
if [ $? -eq 0 -a ${_MM} -eq 12 -a ${_DD} -eq 30 ]; then 
    echo "" > $_FILEDIR/NZBZ.del
    _RQ=${_YY}1231
fi

echo ��������: $_RQ > SUCCESS
ls -l >> SUCCESS

# ������FTP������ƽ̨������
echo ��������*.del �ı���Ŀ¼ /CORE/$_RQ 
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
    echo �����ı���������, ������: $_rest
    exit 10
fi

echo �ɼ����, ʱ��: `date +%Y-%m-%d_%T` 

exit 0
