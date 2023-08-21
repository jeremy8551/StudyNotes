#!/bin/sh

# 初始化参数
source qyzx_param.sh



for i in "${!proc_id[@]}"; do
  str_array[$i]=${proc_id[$i]}
  echo "【$i ${proc_name[$i]} - ${proc_id[$i]}】"
done

exit 0
