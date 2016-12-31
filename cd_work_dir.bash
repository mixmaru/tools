#!/bin/bash

#プロジェクト作業ルートディレクトリへ移動するためのスクリプト

#.bashrcに
# alias cdwkdir='. /some_dir/cd_work_dir.bash /some_dir/cd_work_dir.bash'
# を記入しておき、以下のように使用する
#プロジェクトディレクトリへ移動
# cdwkdir mv プロジェクト名
#プロジェクトを追加
#. ./cd_work_dir.bash このスクリプトのパスを指定 add プロジェクト名 作業ディレクトリパス
# cdwkdir add プロジェクト名 作業ディレクトリパス
#プロジェクト削除
# cdwkdir delete プロジェクト名
#プロジェクト一覧表示
# cdwkdir list

#ここで使用するすべてのグローバル変数は同名の変数が指定されている場合を考慮して、
#内容を一旦既存内容を別変数に保存してから定義する。
#スクリプト終了時に別変数から書き戻す。
TMP_CD_WORK_DIR_SCRIPT_DIR=${SCRIPT_DIR}
TMP_CD_WORK_DIR_SCRIPT_FILE=${SCRIPT_FILE}
TMP_CD_WORK_DIR_LOCK_FILE=${LOCK_FILE}
TMP_CD_WORK_DIR_WORK_DIR=${WORK_DIR}
TMP_CD_WORK_DIR_PROJECT_LIST_FILE=${PROJECT_LIST_FILE}
TMP_CD_WORK_DIR_PROJECT_TMP_FILE=${PROJECT_TMP_FILE}
TMP_CD_WORK_DIR_mode=${mode}
TMP_CD_WORK_DIR_project_name=${project_name}
TMP_CD_WORK_DIR_project_path=${project_path}
TMP_CD_WORK_DIR_error=${error}
TMP_CD_WORK_DIR_dsp_usage_flag=${dsp_usage_flag}

#使用するファイルのパスを用意
#スクリプトがあるディレクトリ
SCRIPT_DIR=$(cd $(dirname $1) && pwd)/
SCRIPT_FILE=${SCRIPT_DIR}cd_work_dir.bash
SCRIPT_FUNCTIONS_FILE=${SCRIPT_DIR}cd_work_dir_functions.bash
#ロック用ファイル
LOCK_FILE=${SCRIPT_DIR}.cdwkdirlock
#設定ファイルディレクトリ
WORK_DIR=~/.cdwkdir/
#設定ファイル
PROJECT_LIST_FILE=${WORK_DIR}project_list
#一時保存ファイル
PROJECT_TMP_FILE=${WORK_DIR}.project_list_tmp

#使用する変数
mode=$2
project_name=$3
project_path=$4
error=()
dsp_usage_flag=0

#関数の定義
source ${SCRIPT_FUNCTIONS_FILE}


#排他ロック
cdwkdir_lock ${SCRIPT_FILE} ${LOCK_FILE}
if [ $? -eq 0 ]; then
    #設定ファイル等がなければ作成する
    if [ ! -d  ${WORK_DIR} ];then
        mkdir ${WORK_DIR}
    fi
    if [ ! -e ${PROJECT_LIST_FILE} ]; then
        touch ${PROJECT_LIST_FILE}
    fi

    #引数からmodeとprojectを取得。エラーならerrorにメッセージを挿入
    case "${mode}" in
        "mv"        )
            if [ -z ${project_name} ];then
                error+=("プロジェクト名を指定してください");
            fi
            if [ ${#error[@]} -eq 0 ];then
                cdwkdir_move ${project_name} ${PROJECT_LIST_FILE}
            else
                dsp_usage_flag=1
            fi
            ;;
        "add"       )
            if [ -z ${project_name} ];then
                error+=("プロジェクト名を指定してください");
            fi
            if [ -z ${project_path} ];then
                error+=("ディレクトリパスを指定してください");
            fi
            if [ ${#error[@]} -eq 0 ];then
                cdwkdir_add ${project_name} ${project_path} ${PROJECT_LIST_FILE}
            else
                dsp_usage_flag=1
            fi
            ;;
        "delete"    )
            if [ -z ${project_name} ];then
                error+=("プロジェクト名を指定してください");
            fi
            if [ ${#error[@]} -eq 0 ];then
                cdwkdir_delete ${project_name} ${PROJECT_LIST_FILE} ${PROJECT_TMP_FILE}
            else
                dsp_usage_flag=1
            fi
            ;;
        "list"      )
            cdwkdir_list ${PROJECT_LIST_FILE}
            ;;
        * )
            dsp_usage_flag=1
            ;;

    esac

    #エラーがあればメッセージを出す
    for message in ${error[@]}
    do
        echo ${message}
    done

    #usage表示
    if [ ${dsp_usage_flag} -ne 0 ];then
        cdwkdir_usage
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
mode=${TMP_CD_WORK_DIR_mode}
project_name=${TMP_CD_WORK_DIR_project_name}
project_path=${TMP_CD_WORK_DIR_project_path}
error=${TMP_CD_WORK_DIR_error}
dsp_usage_flag=${TMP_CD_WORK_DIR_dsp_usage_flag}

#定義関数の削除
unset -f cdwkdir_lock
unset -f cdwkdir_move
unset -f cdwkdir_add
unset -f cdwkdir_delete
unset -f cdwkdir_list
unset -f cdwkdir_usage
