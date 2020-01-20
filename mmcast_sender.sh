#!/bin/bash
# sends multiple multicast streams
if [ $# -le 2 ]
  then
    echo "Usage: ./mmcast_sender.sh <streams> <time> <bound_address>"
    echo "Only do up to 255 streams at once"
    exit
fi

counter=1 # start from 1 as this counter is used to form the string for the multicast group
loops=$1

# make directory to store logs
now=$(date +"%Y-%m-%d-%H-%M-%S")
logdir="${now}_sender/"
mkdir $logdir
printf "Created $logdir\n"


while [ $counter -le $loops ]; do
  # start all the iperf processes as background jobs so they run in parallel
  # example command:
  # iperf --interval 1 --bind 192.168.128.80 --bandwidth 1000k --client 239.255.1.1 --time 100000 --udp --reportstyle C &
  outfile="${logdir}mmcast_send_$counter.log"
  mcast_group="239.255.1."$counter

  echo $mcast_group
  iperf --interval 1 --bind $3 --bandwidth 2000k --client $mcast_group --time $2 --udp --reportstyle C >> $outfile &
  pids[${i}]=$!   # collect PIDs to wait for
  let counter=counter+1
done


# wait for all pids
for pid in ${pids[*]}; do
    wait $pid
done
