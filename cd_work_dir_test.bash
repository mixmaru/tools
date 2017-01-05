#!/bin/bash

#関数の読み込み
source ./cd_work_dir_functions.bash

function echoUsageText(){
    cat <<_EOT_
Usage:
  mv        project_name                projectのディレクトリへ移動する
  add       project_name dir_path       プロジェクト名をproject_name、ディレクトリパスをdir_pathとして新規追加する
  delete    project_name                projectを削除する
  list                                  登録されているproject一覧を表示する
_EOT_
}

function cdwkdir_usage_test(){
    local expect=$(echoUsageText)
    local result=$(cdwkdir_usage)

    if [ "${expect}" = "${result}" ]; then
        return 0
    else
        echo "result:"
        echo "${result}"
        echo
        echo "expect:"
        echo "${expect}"
        return 1
    fi
}

function cdwkdir_lock_test(){
    #前準備
    local tmp_result=0
    local lock_file="./lock_test"
    touch ${lock_file}

    local error_flag=0

    cdwkdir_lock
    tmp_result=$?
    if [ ${tmp_result} -ne 1 ];then
        echo "実行:cdwkdir_lock"
        echo "expect:1"
        echo "result:${tmp_result}"
        error_flag=1
    fi

    cdwkdir_lock ./cd_work_dir_test.bash ${lock_file}
    tmp_result=$?
    if [ ${tmp_result} -ne 1 ];then
        echo "ロックされている状態にて"
        echo "実行:cdwkdir_lock ./cd_work_dir_test.bash ${lock_file}"
        echo "expect:1"
        echo "result:${tmp_result}"
        error_flag=1
    fi

    rm -f ${lock_file}
    cdwkdir_lock ./cd_work_dir_test.bash ${lock_file}
    tmp_result=$?
    if [ ${tmp_result} -ne 0 ];then
        echo "ロックされていない状態にて"
        echo "実行:cdwkdir_lock ./cd_work_dir_test.bash ${lock_file}"
        echo "expect:0"
        echo "result:${tmp_result}"
        error_flag=1
    fi

    #後処理
    rm -f ${lock_file}

    if [ ${error_flag} -eq 0 ]; then
        return 0
    else
        return 1
    fi
}


echo "-----cdwkdir_usageテスト開始-----"
cdwkdir_usage_error=$(cdwkdir_usage_test)
if [ $? -eq 0 ]; then
    echo "ok"
else
    echo "ng"
    echo "${cdwkdir_usage_error}"
fi
echo "-----cdwkdir_usageテスト完了-----"
echo
echo "-----cdwkdir_lockテスト開始-----"
cdwkdir_lock_error=$(cdwkdir_lock_test)
if [ $? -eq 0 ]; then
    echo "ok"
else
    echo "ng"
    echo "${cdwkdir_lock_error}"
fi
echo "-----cdwkdir_lockテスト完了-----"

echo テスト完了
