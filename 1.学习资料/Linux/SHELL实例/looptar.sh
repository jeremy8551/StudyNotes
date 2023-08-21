#!/bin/sh

# 对3天以前的数据文件压缩备份

# 执行压缩删除操作
function execDelAndTar() {
    fileDirs=$HOME/file/input/$1
    
    echo "开始压缩【$1】数据文件 .."
    cd ${fileDirs}
    if [ $? -ne 0 ]; then
        echo 进入目录【${fileDirs}】失败!
        exit 1;
    fi

    # 计算循环次数
    ls -lc | egrep "^.* [0-9]{8}$" > flst.tmp
    lns=`cat flst.tmp|wc -l`
    ((loopTimes=lns-3))
    
    # 循环备份
    while [ $loopTimes -gt 0 ]; do
        dnm=`cat flst.tmp | sed -n ${loopTimes}p | awk -F" " '{print $8}'`
        if [ ! -f "${dnm}.tar" ]; then
            echo 【`date +%Y-%m-%d_%H:%M:%S`】tar -cvf ${dnm}.tar ${dnm} ..
#            msg=`tar -cvf ${dnm}.tar ${dnm}`
            if [ $? -ne 0 ]; then
                echo $msg
            else 
                echo 删除目录 ${fileDirs}/${dnm}
#                rm -rf ${fileDirs}/${dnm}
            fi
        fi
        ((loopTimes=loopTimes-1))
    done
    
    rm flst.tmp
}

execDelAndTar MNA


exit 0