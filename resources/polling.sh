#!/bin/bash

declare -i duration=1
declare hasUrl=""
declare endpoint
declare maxRuns=60
declare currentRun=0

usage() {
    cat <<END
    polling.sh [-i] [-h] endpoint secondsToRun
    
    Report the health status of the endpoint
    -i: include Uri for the format
    -h: help
END
}

while getopts "ih" opt; do 
  case $opt in 
    i)
      hasUrl=true
      ;;
    h) 
      usage
      exit 0
      ;;
    \?)
     echo "Unknown option: -${OPTARG}" >&2
     exit 1
     ;;
  esac
done

shift $((OPTIND -1))

if [[ $1 ]]; then
  endpoint=$1
elif [[ $2 ]]; then
  maxRuns=$2
else
  echo "Please specify the endpoint."
  usage
  exit 1 
fi 


healthcheck() {
    declare url=$1
    result=$(curl -i $url 2>/dev/null | grep "HTTP/1.1")
    echo $result
}

while [[ true && $currentRun < $maxRuns ]]; do
   result=`healthcheck $endpoint` 
   declare status
   if [[ -z $result ]]; then 
      status="N/A"
      exit 1
   else
      status=${result:9:3}
      if (($status == '200'))
      then
        echo "Service is up!"
        exit 0
      fi
   fi 
   timestamp=$(date "+%Y%m%d-%H%M%S")
   if [[ -z $hasUrl ]]; then
     echo "$timestamp | $status "
   else
     echo "$timestamp | $status | $endpoint " 
   fi
   ((currentRun++))
   sleep $duration   
done
echo "finished running"
exit 1;