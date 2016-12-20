#!/bin/bash

cd `dirname $0`

#path="$(cat ./.cdwkdir | awk '{print $2}')"
#echo ${path} > ./out.txt

project_name=$1
echo $1

count_command="cat ./.cdwkdir | awk 'BEGIN{count=0} \$1==\"${project_name}\"{count+=1} END{print count}'"
count=$(eval ${count_command})

if [ ${count} == 1 ]; then
    echo "ok"
else
    echo "ng"
fi
