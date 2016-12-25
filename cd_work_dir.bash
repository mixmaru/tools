#!/bin/bash

#cartプロジェクトへ移動する場合
#. ./cd_work_dir.bash ~/Dropbox/tools/cd_work_dir.bash cart

#使用するファイルのパスを用意
#スクリプトがあるディレクトリ
script_dir=$(cd $(dirname $1) && pwd)/
script_file=${script_dir}cd_work_dir.bash
#ロック用ファイル
lock_file=${script_dir}.cdwkdirlock
#設定ファイルディレクトリ
work_dir=${script_dir}.cdwkdir/
#設定ファイル
setting_file=${work_dir}config
#一時保存ファイル
setting_tmp_file=${work_dir}config_tmp

#使用する変数
mode=
project=
error=

#関数の定義
#排他ロック。参考）http://qiita.com/hidetzu/items/11f92f941efbb182f757
function lock(){
    local is_lock="no"
    ln -s $1 ${lock_file} 2> /dev/null || is_lock="yes"
    if [ ${is_lock} = "yes" ]; then
        return 1
    else
        return 0
    fi
}

#カレントディレクトリの移動
function move(){
    local project_name=$1
    #指定プロジェクトの行数を取得
    local count_command="cat ${setting_file} | awk 'BEGIN{count=0} \$1==\"${project_name}\"{count+=1} END{print count}'"
    local count=$(eval ${count_command})

    #行数が1なら正常。そうでないなら異常なので処理終了
    if [ ${count} -eq 0 ]; then
        error="${project_name}の設定は存在しません"
        return 1
    elif [ ${count} -ge 2 ]; then
        error="${project_name}の設定が複数あります。${setting_file} を確認してください"
        return 1
    fi

    #パスを取り出す
    local path_command="cat ${setting_file} | awk '\$1==\"${project_name}\"{print \$2}'"
    local target_path=$(eval ${path_command})
    cd ${target_path}
}

#プロジェクトパスデータの追加 add 追加プロジェクト名 パス
function add(){
    local name=$1
    local path=$2
    #存在しないかチェック
    local tmp_command="cat ${setting_file} | awk '\$1==\"${name}\"{print \$1}'"
    local result=($(eval ${tmp_command}))
    if [ ${#result[@]} -eq 0 ];then
        #追加処理
        echo "${name} ${path}" >> ${setting_file}
        return 0
    else
        error="すでに${name}が存在します"
        return 1
    fi
}

#プロジェクト削除 delete プロジェクト名
function delete(){
    local name=$1
    local tmp_command="cat ${setting_file} | awk '\$1!=\"${name}\"{print \$0}'"

    #指定プロジェクトを除去した設定ファイルの一時ファイルを作成
    eval ${tmp_command} > ${setting_tmp_file}
    #元ファイルと比較して、変更があれば元ファイルを上書きする
    local tmp_command="diff ${setting_file} ${setting_tmp_file}"
    local diff_res=$(eval ${tmp_command})

    if [ -n "${diff_res}" ];then
        cat ${setting_tmp_file} > ${setting_file}
        rm ${setting_tmp_file}
        return 0
    else
        error="${name}は存在しません"
        return 1
    fi
}
#メインの第2引数と第三引数を見てmodeとprojectをセットする
#getOption $2 $3
function getOption(){
    if [ -n "$1" ] && [ -z "$2" ]; then
        mode="move"
        project=$1
    elif [ -n "$1" ] && [ -n "$2" ]; then
        case "$1" in
            "add"       )
                if [ -n "$3" ];then
                    mode="add"
                    project=$2
                    project_path=$3
                fi
                ;;
            "delete"    )
                mode="delete"
                project=$2
                ;;
        esac
    fi
    if [ -n "${mode}" ]; then
        return 0
    else
        return 1
    fi
}

lock ${script_file}
if [ $? -eq 0 ]; then
    #引数からmodeとprojectを取得。エラーならerrorにメッセージを挿入
    getOption $2 $3 $4
    if [ $? -eq 0 ];then
        #メイン処理実行
       ${mode} ${project} ${project_path}
    fi

    #エラーがあればメッセージを出す
    if [ -n "${error}" ]; then
        echo ${error}
    fi

    #ロック開放
    rm -f ${lock_file}
else
    echo "多重起動防止"
fi




#関数の定義
#function move(){
#    local project_name=$1
#    #指定プロジェクトの行数を取得
#    local count_command="cat ${setting_file} | awk 'BEGIN{count=0} \$1==\"${project_name}\"{count+=1} END{print count}'"
#    local count=$(eval ${count_command})
#
#    #行数が1なら正常。そうでないなら異常なので処理終了
#    if [ ${count} -eq 0 ]; then
#        errorExit "${project_name}の設定は存在しません"
#    elif [ ${count} -ge 2 ]; then
#        errorExit "${project_name}の設定が複数あります。${setting_file} を確認してください"
#    fi
#
#    #パスを取り出す
#    local path_command="cat ${setting_file} | awk '\$1==\"${project_name}\"{print \$2}'"
#    local target_path=$(eval ${path_command})
#    cd ${target_path}
#}
#function add(){
#    echo "add"
#    echo $1
#}
#function modify(){
#    echo "modify"
#    echo $1
#}
#function delete(){
#    echo "delete"
#    echo $1
#}
#function errorExit(){
#    echo $1
#    #ロック開放
#    rm -f ${lock_file}
#    exit 0;
#}
#
##処理モードとプロジェクト名を取得
#mode="unset"
#if [ $# = 2 ]; then
#    mode="move"
#    project=$2
#elif [ $# = 3 ]; then
#    case "$1" in
#        "add"       )
#            mode="add"
#            project=$3
#            ;;
#        "modify"    )
#            mode="modify"
#            project=$3
#            ;;
#        "delete"    )
#            mode="delete"
#            project=$3
#            ;;
#    esac
#fi
#
##引数が正しく指定されなかった場合
#if [ "${mode}" = "unset" ];then
#    errorExit "引数を正しく指定してください"
#fi
#
#
##メイン処理実行
#${mode} ${project}
#
#
##ロック開放
#rm -f ${lock_file}

