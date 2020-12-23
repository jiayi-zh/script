#!/bin/bash
## local
localIp="192.168.9.247"
weedShDir="/opt/gato_bin/third_bin/file_server"
## master
masterIp="192.168.9.247"
masterPort=9333
## slaver
volumeAddr=("/opt/gato_bin/third_bin/file_server/vdata1" "/opt/gato_bin/third_bin/file_server/vdata2" "/opt/gato_bin/third_bin/file_server/vdata3")
volumePort=(9080 9081 9082)
volumnPerCap=(5 5 5)
## ignore start master
ignoreStartMaster=false

# stop weed
eval "killall -9 weed"
echo "kill seaweedFs old process"

sleep 1

# clean volumn disk
for volume in ${volumeAddr[*]}
do
    eval "rm -rf $volume/*"
    echo "clean disk: $volume"
done

# start master
if $ignoreStartMaster
then
    echo "skip start seadweedFS master"
else
    eval "nohup $weedShDir/weed master -ip=$masterIp -port=$masterPort -mdir=$weedShDir/mdata -defaultReplication=000 >$weedShDir/weed_master.log 2>&1 &"
    echo "start seadweedFS master($masterIp:$masterPort)"
fi

#start slaver
for i in "${!volumeAddr[@]}"
do
    eval "nohup $weedShDir/weed volume -ip=$localIp -port=${volumePort[$i]} -mserver=$masterIp:$masterPort -dir=${volumeAddr[$i]} >$weedShDir/weed_volumn${volumePort[$i]}.log -max=${volumnPerCap[$i]} 2>&1 &"
    echo "start seadweedFS slaver($localIp:${volumePort[$i]})"
done