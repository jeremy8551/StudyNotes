#! /usr/bin/ksh

# ѭ���������� 
# ����������ݵ��ļ��������Ѿ��ﵽ10�� �Զ�ɾ�����籣�������

cday=`date +%Y%m%d`


if [ -d jgjrtj${cday} ]; then
  mv jgjrtj${cday} jgjrtj${cday}-`date +%s` 
fi
mkdir jgjrtj${cday}


# ��ȡ��ǰ�ѱ������������
fn=`ls -l|egrep jgjrtj[0-9]{8}$|wc -l`
if [ $fn -gt 10 ]; then 
  minDir=`ls -lc|egrep jgjrtj[0-9]{8}$|sed -n 1p|awk -F" " '{print $9}'`
  if [ -d $minDir ]; then 
    echo ɾ��Ŀ¼ $minDir
    rm -rf $minDir
  fi
fi

echo exit
