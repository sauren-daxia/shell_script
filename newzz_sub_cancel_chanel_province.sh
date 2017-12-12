#!/bin/sh
. /usr/local/app/dana/current/shbb/profile
#. /home/shihy/bin/shbb_20090423/profile

usage () {
    echo "usage: $0  target_dir" 1>&2
    exit 2
}

if [ $# -lt 1 ] ; then
    usage
fi
V_DATE=$1
V_YEAR=$(echo $V_DATE | cut -c 1-4)
SOURCE_DIR=$AUTO_DATA_TARGET/$V_YEAR/$V_DATE
TARGET_DIR=$AUTO_DATA_REPORT/$V_YEAR/$V_DATE
CODE_DIR=$AUTO_DATA_NODIST

if [ ! -d "$TARGET_DIR" ]; then
  if ! mkdir -p $TARGET_DIR
  then
    echo "mkdir $TARGET_DIR error"
    exit 1
  fi
fi

if [ ! -d "$SOURCE_DIR" ]; then
  echo "$SOURCE_DIR not found"
  exit 1
fi

 #创建实名管道
 if [ ! -f "$TARGET_DIR/$$_tmp" ];then
   mkfifo $TARGET_DIR/$$_tmp
 fi
   # 源文件
   sour_filename=$SOURCE_DIR/usa_action_log.${V_DATE}.txt

   # 结果文件
    target_filename=$TARGET_DIR/report.region.newzz_sub_cancel_chanel_province.csv
    target_filename_1=$TARGET_DIR/report.region.newzz_sub_cancel_chanel_country.csv
    target_filename_2=$TARGET_DIR/report.region.newzz_sub_cancel_chanel_noappcode_province.csv
   # 字典表文
   code_file=$CODE_DIR/shbb_chanel_code.txt
   zzcode_file_new=$CODE_DIR/news_appcode.txt

   ERROR=0


  awk -F\| '{
            if(FILENAME=="'$zzcode_file_new'")
            {
            	new_appcode[$1]=$2
            }
            else if($7 in new_appcode){
            # 订阅结构与退订结构不同，所以此处NF不能修改
            action=$2;userid=$3;servicecode=$6;appcode=$7;proviceno=$(NF-4)","$(NF-5)"|"new_appcode[$7]
            # 订阅结构与退订结构不同
            if(action=="cancel")
            {
               chanel_cancel=$11
            }
            else if(action=="subscribe")
            {
               chanel_subscribe=$12
            }
            #记录省份信息
            if(action=="cancel" || action=="subscribe")
            {
               arr_index=proviceno"|"appcode"|"userid
               p[arr_index]=1
               if(action=="subscribe")
               {
                 subcrib_user[arr_index]=$23 # 订阅次数
                 subcrib_user_chanel[arr_index]=chanel_subscribe
               }
               else
               {
                 cancel_user[arr_index]=$19  #退订次数
                 cancel_user_chanel[arr_index]=chanel_cancel
               }
               # 订阅结构与退订结构不同，所以此处NF不能修改
               flag[arr_index]=flag[arr_index]$(NF) #第一动作
            }
           }
          }END{
            for (name in p)
            {
               a=(subcrib_user[name]>0) ? subcrib_user[name]:0
               b=(cancel_user[name]>0) ? cancel_user[name]:0
               printf("%s|%d|%d|%s|%s|%s\n",name,a,b,subcrib_user_chanel[name],cancel_user_chanel[name],flag[name])
            }
  }' $zzcode_file_new $sour_filename >$TARGET_DIR/$$_tmp&
            #开始生成报表
            awk -F\| '{
            if(FILENAME=="'$code_file'")
            {
               chanel_name=$1
               is_display=$2
               if(is_display>0)
               {
                  i++
                  chanel_code[chanel_name]=is_display
                  chanel_code_order[i]=chanel_name
               }
            }
            else
            {
               proviceName=$1;sevicename=$2;subcribe_num=$5;cancel_num=$6;appcode_name=$3;action_str=$9
               chanel_cancel=$8
               chanel_subscribe=$7
               if(!(chanel_cancel in chanel_code))
               {
                 chanel_cancel="OTHERS"
               }
              if(!(chanel_subscribe in chanel_code))
               {
                 chanel_subscribe="OTHERS"
               }
               flag=subcribe_num-cancel_num
               indexstr=proviceName","sevicename","appcode_name
               indexstr_1=sevicename","appcode_name
               indexstr_2=proviceName","sevicename
               p[indexstr]=1
               p_1[indexstr_1]=1
               p_2[indexstr_2]=1

               #定阅用户
               if(flag>=1)
               {
                 subscribe[indexstr","chanel_subscribe]++
                 subscribe_1[indexstr_1","chanel_subscribe]++
                 subscribe_2[indexstr_2","chanel_subscribe]++
               }
               #退订用户
               else if(flag<=-1)
               {
                  cancel[indexstr","chanel_cancel]++
                  cancel_1[indexstr_1","chanel_cancel]++
                  cancel_2[indexstr_2","chanel_cancel]++
               }
               else if((flag==0) &&(action_str=="subscribe"))
               {
                  subscribe_cancel[proviceName","sevicename","appcode_name] ++
                  subscribe_cancel_1[sevicename","appcode_name] ++
                  subscribe_cancel_2[proviceName","sevicename] ++

                }
                else if((flag==0) &&(action_str=="cancel"))
                {
                   cancel_subscribe[proviceName","sevicename","appcode_name] ++
                   cancel_subscribe_1[sevicename","appcode_name] ++
                   cancel_subscribe_2[proviceName","sevicename] ++

                }

            }
            }END{
            # 输出标题
            i++
            chanel_code_order[i]="OTHERS"
            for(m=1;m<=i;m++)
            {
               k=chanel_code_order[m]
               str1=str1",订阅用户("k")"
               str2=str2",退订用户("k")"
            }
            str3="省编码,省份名称,杂志名称,APPCODE"
            printf("%s%s%s,%s,%s\n",str3,str1,str2,"当日即订即退","当日即退即订")>"'$target_filename'"
            str3="合计,杂志名称,APPCODE"
            printf("%s%s%s,%s,%s\n",str3,str1,str2,"当日即订即退","当日即退即订")>"'$target_filename_1'"
            str3="省编码,省份名称,杂志名称"
            printf("%s%s%s,%s,%s\n",str3,str1,str2,"当日即订即退","当日即退即订")>"'$target_filename_2'"
            for (provi in p)
            {
               str1=""
               str2=""
               for(m=1;m<=i;m++)
               {
                    k=chanel_code_order[m]
                    subscribe_num=(subscribe[provi ","k]>0)?subscribe[provi ","k]:0
                    cancel_num=(cancel[provi ","k]>0)?cancel[provi ","k]:0
                    str1=str1","subscribe_num
                    str2=str2","cancel_num
               }
               printf("%s%s%s,%d,%d\n",provi,str1,str2,subscribe_cancel[provi],cancel_subscribe[provi])>>"'$target_filename'"
            }
            for (provi in p_1)
            {
               str1=""
               str2=""
               for(m=1;m<=i;m++)
               {
                    k=chanel_code_order[m]
                    subscribe_num=(subscribe_1[provi ","k]>0)?subscribe_1[provi ","k]:0
                    cancel_num=(cancel_1[provi ","k]>0)?cancel_1[provi ","k]:0
                    str1=str1","subscribe_num
                    str2=str2","cancel_num
               }
               printf("%s,%s%s%s,%d,%d\n","合计",provi,str1,str2,subscribe_cancel_1[provi],cancel_subscribe_1[provi])>>"'$target_filename_1'"
            }
            for (provi in p_2)
            {
               str1=""
               str2=""
               for(m=1;m<=i;m++)
               {
                    k=chanel_code_order[m]
                    subscribe_num=(subscribe_2[provi ","k]>0)?subscribe_2[provi ","k]:0
                    cancel_num=(cancel_2[provi ","k]>0)?cancel_2[provi ","k]:0
                    str1=str1","subscribe_num
                    str2=str2","cancel_num
               }
               printf("%s%s%s,%d,%d\n",provi,str1,str2,subscribe_cancel_2[provi],cancel_subscribe_2[provi])>>"'$target_filename_2'"
            }
        }' $code_file $TARGET_DIR/$$_tmp
        ERROR=$?
	      rm $TARGET_DIR/$$_tmp
  			if [ $ERROR -gt 0 ]; then
   				exit 1
 			 	else
					wait $!
  			fi



