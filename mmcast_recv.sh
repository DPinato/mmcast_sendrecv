#!/bin/bash
# receive multiple multicast streams
if [ $# -le 2 ]
  then
    echo "Usage: ./mmcast_recv.sh <streams> <time> <interface>"
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
  # iperf --interval 1 --bind 239.255.1.1%en8 --udp --server --time 100000 --reportstyle C &
  outfile="${logdir}mmcast_recv_$counter.log"
  mcast_group="239.255.1."$counter

  echo $mcast_group
  iperf --interval 1 --bind $mcast_group%$3 --udp --server --time $2 --reportstyle C >> $outfile &
  pids[${i}]=$!   # collect PIDs to wait for
  let counter=counter+1
done


# wait for all pids
for pid in ${pids[*]}; do
    wait $pid
done
