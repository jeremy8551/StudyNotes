
# 读取 default.ini 文件中的信息
awk '{print $0}' default.ini | while read line   
do  
    echo $line  
done   
  
for循环：   
for (( i=1;  i<=100;  i=i+1 ))   
do  
   s=$(($s+$i))   
done  


######################################
function while_read_LINE
{
cat $FILENAME | while read LINE
do
        echo "$LINE"
        :
done
}

######################################
function while_read_LINE_bottom 
{
while read LINE
do
        echo "$LINE"
        :

done < $FILENAME
}

######################################
function while_line_LINE_bottom
{
while line LINE
do
        echo $LINE
        :
done < $FILENAME
}

######################################
function cat_while_LINE_line  
{
cat $FILENAME | while LINE=`line`
do
        echo "$LINE"
        :
done
}

######################################
function while_line_LINE
{
cat $FILENAME | while line LINE
do
        echo "$LINE"
        :
done
}

######################################
function while_LINE_line_bottom 
{
while LINE=`line`
do
        echo "$LINE"
        :

done < $FILENAME 
}

######################################
function while_LINE_line_cmdsub2 
{
cat $FILENAME | while LINE=$(line)
do
        echo "$LINE"
        :
done
}

######################################
function while_LINE_line_bottom_cmdsub2 
{
while LINE=$(line)
do
        echo "$LINE"
        :

done < $FILENAME 
}

######################################
function while_read_LINE_FD 
{
exec 3<&0
exec 0< $FILENAME
while read LINE
do
        echo "$LINE"
        :
done
exec 0<&3
}

######################################
function while_LINE_line_FD 
{
exec 3<&0
exec 0< $FILENAME
while LINE=`line`
do
        echo "$LINE"
        :
done
exec 0<&3
}

######################################
function while_LINE_line_cmdsub2_FD
{
exec 3<&0
exec 0< $FILENAME
while LINE=$(line)
do
        print "$LINE"
        :
done
exec 0<&3
}

######################################
function while_line_LINE_FD 
{
exec 3<&0
exec 0< $FILENAME

while line LINE
do
        echo "$LINE"
        :
done

exec 0<&3
}

