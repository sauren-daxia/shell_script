-25上
[gateway@wtraffic /data/match/cmpp/20171114]$ cat outputumessage_005_wuxian_20171114_cmpp.out | grep '15131774828'
Nov 14 09:48:49 192.100.6.11 Monster-CMPP20MT[23537]: 20171114094849SMS01020106231115d0b4ca09937f1,0,1,000,0311,157678,I,wuxian_qianxiang,0,10658880,03,15131774828,1,15131774828,10201062,1,,,UMGJTXM,02,100,0,0,0,0,8,1114b42dceeef9238173ea1d178f3252a1e9,0,5,0,901808,11140948510101037043,0,50,12580交通小秘书业务测试，感谢支持！,311,317,Nov 14 09:48:53 192.100.6.5 Monster-CMPP20REPORT[74166]: 000000,11140948510101037043,0,0,15131774828,201711140948,201711140948
---倒数第四个为结果
[gateway@wtraffic /data/match/cmpp/20171113]$ cat outputumessage_005_wuxian_20171113_cmpp.out | grep  -E "18747974497|15140051555|15107105290|18777136602|13997267018|13893287847|18295317435|15808700867|15129051851|15105719009|13518991862|15097301169|15080470481|13908053254|15874244710|15098728821|18702224964|17839989937|13883075735|15765541340|15104469667|13643617449|18786797015|18705698425|18290865069|15970477352|18321646092|13717826274|15051518443" >> ~/wz_report.txt
cat wz_report.txt | sed -n '86,260p' > result.txt
