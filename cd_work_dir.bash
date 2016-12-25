#!/bin/bash

#cartプロジェクトへ移動する場合
#. ./cd_work_dir.bash ~/Dropbox/tools/cd_work_dir.bash cart

#ここで使用するすべてのグローバル変数は同名の変数が指定されている場合を考慮して、
#内容を一旦既存内容を別変数に保存してから定義する。
#スクリプト終了時に別変数から書き戻す。
TMP_CD_WORK_DIR_SCRIPT_DIR=${SCRIPT_DIR}
TMP_CD_WORK_DIR_SCRIPT_FILE=${SCRIPT_FILE}
TMP_CD_WORK_DIR_LOCK_FILE=${LOCK_FILE}
TMP_CD_WORK_DIR_WORK_DIR=${WORK_DIR}
TMP_CD_WORK_DIR_PROJECT_LIST_FILE=${PROJECT_LIST_FILE}
TMP_CD_WORK_DIR_PROJECT_TMP_FILE=${PROJECT_TMP_FILE}

#使用するファイルのパスを用意
#スクリプトがあるディレクトリ
SCRIPT_DIR=$(cd $(dirname $1) && pwd)/
SCRIPT_FILE=${SCRIPT_DIR}cd_work_dir.bash
#ロック用ファイル
LOCK_FILE=${SCRIPT_DIR}.cdwkdirlock
#設定ファイルディレクトリ
WORK_DIR=${SCRIPT_DIR}.cdwkdir/
#設定ファイル
PROJECT_LIST_FILE=${WORK_DIR}project_list
#一時保存ファイル
PROJECT_TMP_FILE=${WORK_DIR}.project_list_tmp

#使用する変数
mode=
project=
error=

#関数の定義
#排他ロック。参考）http://qiita.com/hidetzu/items/11f92f941efbb182f757
function lock(){
    local is_lock="no"
    ln -s $1 ${LOCK_FILE} 2> /dev/null || is_lock="yes"
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
    local count_command="cat ${PROJECT_LIST_FILE} | awk 'BEGIN{count=0} \$1==\"${project_name}\"{count+=1} END{print count}'"
    local count=$(eval ${count_command})

    #行数が1なら正常。そうでないなら異常なので処理終了
    if [ ${count} -eq 0 ]; then
        error="${project_name}の設定は存在しません"
        return 1
    elif [ ${count} -ge 2 ]; then
        error="${project_name}の設定が複数あります。${PROJECT_LIST_FILE} を確認してください"
        return 1
    fi

    #パスを取り出す
    local path_command="cat ${PROJECT_LIST_FILE} | awk '\$1==\"${project_name}\"{print \$2}'"
    local target_path=$(eval ${path_command})
    cd ${target_path}
}

#プロジェクトパスデータの追加 add 追加プロジェクト名 パス
function add(){
    local name=$1
    local path=$2
    #存在しないかチェック
    local tmp_command="cat ${PROJECT_LIST_FILE} | awk '\$1==\"${name}\"{print \$1}'"
    local result=($(eval ${tmp_command}))
    if [ ${#result[@]} -eq 0 ];then
        #追加処理
        echo "${name} ${path}" >> ${PROJECT_LIST_FILE}
        return 0
    else
        error="すでに${name}が存在します"
        return 1
    fi
}

#プロジェクト削除 delete プロジェクト名
function delete(){
    local name=$1
    local tmp_command="cat ${PROJECT_LIST_FILE} | awk '\$1!=\"${name}\"{print \$0}'"

    #指定プロジェクトを除去した設定ファイルの一時ファイルを作成
    eval ${tmp_command} > ${PROJECT_TMP_FILE}
    #元ファイルと比較して、変更があれば元ファイルを上書きする
    local tmp_command="diff ${PROJECT_LIST_FILE} ${PROJECT_TMP_FILE}"
    local diff_res=$(eval ${tmp_command})

    if [ -n "${diff_res}" ];then
        cat ${PROJECT_TMP_FILE} > ${PROJECT_LIST_FILE}
        rm ${PROJECT_TMP_FILE}
        return 0
    else
        error="${name}は存在しません"
        rm ${PROJECT_TMP_FILE}
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

#排他ロック
lock ${SCRIPT_FILE}

#設定ファイル等がなければ作成する
if [ ! -d  ${WORK_DIR} ];then
    mkdir ${WORK_DIR}
fi
if [ ! -e ${PROJECT_LIST_FILE} ]; then
    touch ${PROJECT_LIST_FILE}
fi

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
    rm -f ${LOCK_FILE}
else
    echo "多重起動防止"
fi

#既存変数の書き戻し
SCRIPT_DIR=${TMP_CD_WORK_DIR_SCRIPT_DIR}
SCRIPT_FILE=${TMP_CD_WORK_DIR_SCRIPT_FILE}
LOCK_FILE=${TMP_CD_WORK_DIR_LOCK_FILE}
WORK_DIR=${TMP_CD_WORK_DIR_WORK_DIR}
PROJECT_LIST_FILE=${TMP_CD_WORK_DIR_PROJECT_LIST_FILE}
PROJECT_TMP_FILE=${TMP_CD_WORK_DIR_PROJECT_TMP_FILE}
