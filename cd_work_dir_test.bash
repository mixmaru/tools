#!/bin/bash

#関数の読み込み
source ./cd_work_dir_functions.bash



#各テスト、メイン関数

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

#テスト実行用関数
#execTest 実行コマンド文字列（必須） 予測返り値（必須） 予測標準出力（任意） 補足テキスト(任意)
#出力:
#実行コマンド
#補足テキスト
#結果(ok or ng)
#errorテキスト(ngの場合)

function execTest(){
    local command=$1
    local expect_return=$2
    local expect_out=$3
    local support_text=$4

    local return=0
    local error_message=()


    #テスト実行
    #返り値の比較
    local result_out=$(${command})
    local result_return=$?
    if [ "${result_return}" != "${expect_return}" ]; then
        return=1
        local error_out_command="cat <<_EOT_
---
戻り値が予測と異なる
expect:
${expect_return}
result:
${result_return}
---
_EOT_"
        local error_message="$(eval "${error_out_command}")"
        error_messages+=("${error_message}")
    fi

    #標準出力の比較
    if [ "${result_out}" != "${expect_out}" ]; then
        return=1
        local error_out_command="cat <<_EOT_
---
標準出力が予測と異なる
expect:
${expect_out}
result:
${result_out}
---
_EOT_"
        local error_message="$(eval "${error_out_command}")"
        error_messages+=("${error_message}")
    fi

    #テスト結果
    if [ ${return} -eq 0 ]; then
        local result_text="OK"
    else
        local result_text="NG"
    fi

    #結果出力
    echo "${0} を実行 *****************"
    echo "${support_text}"
    echo "${result_text}"
    for message in ${error_messages[@]}
    do
      echo "${message}"
    done

    return ${return}
}

function echoUsageText(){
    cat <<_EOT_
Usage:
  mv        project_name                projectのディレクトリへ移動する
  add       project_name dir_path       プロジェクト名をproject_name、ディレクトリパスをdir_pathとして新規追加する
  delete    project_name                projectを削除する
  list                                  登録されているproject一覧を表示する
_EOT_
}


#実験ここから
    #前準備
    tmp_result=0
    lock_file="./lock_test"
    error_flag=0

    test_command="cdwkdir_lock"

    execTest ${test_command} 1 "予測テキスト" "補足テキスト"
    exit
#実験ここまで


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
