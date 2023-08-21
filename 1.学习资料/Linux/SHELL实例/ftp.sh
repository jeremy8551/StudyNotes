#!/bin/sh

# Ŀ¼
I_FILE_DIR=/hrbnkapp/frntapp/runtime/settlefile/20100223

ftp -n -u -i 130.1.9.29 <<+
   user frntapp frntapp
   binary
   prompt
   cd $I_FILE_DIR
   ls IFD*IEXR flst.txt
   y
   bye
+

fln=`sed -n '1'p flst.txt|awk -F" " 'NR==1,NR==1 {print $9}'`
echo " "
echo $fln

ftp -n -u -i 130.1.9.29 <<+
   user frntapp frntapp
   binary
   prompt
   cd $I_FILE_DIR
   get $fln
   bye
+

