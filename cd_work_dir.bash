#!/bin/bash

#cartプロジェクトへ移動する場合
#. ./cd_work_dir.bash ~/Dropbox/tools/cd_work_dir.bash cart

#使用するファイルのパスを用意
#スクリプトがあるディレクトリ
script_dir=$(cd $(dirname $1) && pwd)/
#ロック用ファイル
lock_file=${script_dir}.cdwkdirlock
#設定ファイルディレクトリ
work_dir=${script_dir}.cdwkdir/
#設定ファイル
setting_file=${work_dir}config


#排他ロック。参考）http://qiita.com/hidetzu/items/11f92f941efbb182f757
is_lock="no"
ln -s $1 ${lock_file} 2> /dev/null || is_lock="yes"
if [ ${is_lock} = "yes" ]; then
    echo "多重起動防止" 1>&2
    exit 1
fi


#関数の定義
function move(){
    local project_name=$1
    #指定プロジェクトの行数を取得
    local count_command="cat ${setting_file} | awk 'BEGIN{count=0} \$1==\"${project_name}\"{count+=1} END{print count}'"
    local count=$(eval ${count_command})

    #行数が1なら正常。そうでないなら異常なので処理終了
    if [ ${count} -eq 0 ]; then
        errorExit "${project_name}の設定は存在しません"
    elif [ ${count} -ge 2 ]; then
        errorExit "${project_name}の設定が複数あります。${setting_file} を確認してください"
    fi

    #パスを取り出す
    local path_command="cat ${setting_file} | awk '\$1==\"${project_name}\"{print \$2}'"
    local target_path=$(eval ${path_command})
    cd ${target_path}
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
function errorExit(){
    echo $1
    #ロック開放
    rm -f ${lock_file}
    exit 0;
}

#処理モードとプロジェクト名を取得
mode="unset"
if [ $# = 2 ]; then
    mode="move"
    project=$2
elif [ $# = 3 ]; then
    case "$1" in
        "add"       )
            mode="add"
            project=$3
            ;;
        "modify"    )
            mode="modify"
            project=$3
            ;;
        "delete"    )
            mode="delete"
            project=$3
            ;;
    esac
fi

#引数が正しく指定されなかった場合
if [ "${mode}" = "unset" ];then
    errorExit "引数を正しく指定してください"
fi


#メイン処理実行
${mode} ${project}


#ロック開放
rm -f ${lock_file}

