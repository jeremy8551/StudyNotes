#!/bin/sh

# ��3����ǰ�������ļ�ѹ������

# ִ��ѹ��ɾ������
function execDelAndTar() {
    fileDirs=$HOME/file/input/$1
    
    echo "��ʼѹ����$1�������ļ� .."
    cd ${fileDirs}
    if [ $? -ne 0 ]; then
        echo ����Ŀ¼��${fileDirs}��ʧ��!
        exit 1;
    fi

    # ����ѭ������
    ls -lc | egrep "^.* [0-9]{8}$" > flst.tmp
    lns=`cat flst.tmp|wc -l`
    ((loopTimes=lns-3))
    
    # ѭ������
    while [ $loopTimes -gt 0 ]; do
        dnm=`cat flst.tmp | sed -n ${loopTimes}p | awk -F" " '{print $8}'`
        if [ ! -f "${dnm}.tar" ]; then
            echo ��`date +%Y-%m-%d_%H:%M:%S`��tar -cvf ${dnm}.tar ${dnm} ..
#            msg=`tar -cvf ${dnm}.tar ${dnm}`
            if [ $? -ne 0 ]; then
                echo $msg
            else 
                echo ɾ��Ŀ¼ ${fileDirs}/${dnm}
#                rm -rf ${fileDirs}/${dnm}
            fi
        fi
        ((loopTimes=loopTimes-1))
    done
    
    rm flst.tmp
}

execDelAndTar MNA


exit 0