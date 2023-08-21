#!/bin/sh

# 只有udsf用户才能连数据库
su - udsf "-c /home/udsf/shell/qyzx/m_file/loadToInterface.sh $1 $2 $3 $4 -9 -u"