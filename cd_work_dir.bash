#!/bin/bash

#ロックファイルの存在確認
#ロックファイルの作成


#使用するファイルのパスを用意
#スクリプトがあるディレクトリ
script_dir=$(cd $(dirname $0) && pwd)/
#ロック用ファイル
lock_file=${script_dir}.cdwkdirlock
#設定ファイルディレクトリ
work_dir=${script_dir}.cdwkdir/
#設定ファイル
setting_file=${work_dir}config


#排他ロック。参考）http://qiita.com/hidetzu/items/11f92f941efbb182f757
is_lock="no"
ln -s $0 ${lock_file} 2> /dev/null || is_lock="yes"
if [ ${is_lock} = "yes" ]; then
    echo "多重起動防止" 1>&2
    exit 1
fi


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


#処理モードとプロジェクト名を取得
mode="unset"
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

#引数が正しく指定されなかった場合
if [ "${mode}" = "unset" ];then
    echo "引数を正しく指定してください"
    #ロック開放
    rm -f ${lock_file}
    exit 0;
fi


#メイン処理実行
${mode} ${project}


#ロック開放
rm -f ${lock_file}

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
