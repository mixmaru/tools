#!/bin/bash

#ロックファイルの存在確認
#ロックファイルの作成


#使用するファイルのパスを用意
#work_dir_path=スクリプトがあるディレクトリの/.cdwkdirディレクトリ
#setting_file=${work_dir_path}config
#lock_file=${work_dir_path}.lock

#関数の定義
function getopt(){
    echo "getopt"
    echo $1
}
function move(){
    echo "move"
    echo $1
}
function add(){
    echo "add"
    echo $1
}
function modify(){
    echo "modify"
    echo $1
}
function delete(){
    echo "delete"
    echo $1
}

mode="unset"
#処理モードとプロジェクト名を取得
if [ $# = 1 ]; then
    mode="move"
    project=$1
elif [ $# = 2 ]; then
    case "$1" in
        "add"       )
            mode="add"
            project=$2
            ;;
        "modify"    )
            mode="modify"
            project=$2
            ;;
        "delete"    )
            mode="delete"
            project=$2
            ;;
    esac
fi

if [ "${mode}" = "unset" ];then
    echo "引数を正しく指定してください"
    exit 0;
fi

case "${mode}" in
  "move"    ) move ${project};;
  "add"     ) add ${project};;
  "modify"  ) modify ${project};;
  "delete"  ) delete ${project};;
esac



#project_name=$1
#
#count_command="cat ./.cdwkdir | awk 'BEGIN{count=0} \$1==\"${project_name}\"{count+=1} END{print count}'"
#count=$(eval ${count_command})
#
#if [ ${count} == 1 ]; then
#    echo "ok"
#else
#    echo "ng"
#fi
