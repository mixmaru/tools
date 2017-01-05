#!/bin/bash

#関数の読み込み
source ./cd_work_dir_functions.bash



#各テスト、メイン関数

function cdwkdir_usage_test(){
    local test_command="cdwkdir_usage"
    local expect_return=0
    local expect_out=$(echoUsageText)

    execTest "${test_command}" "${expect_return}" "${expect_out}"
    return $?
}

function cdwkdir_lock_test(){
    #前準備
    local tmp_result=0
    local lock_file="./lock_test"
    touch ${lock_file}

    local error_flag=0

    local test_command="cdwkdir_lock"
    local expect_return=1
    local expect_out=
    execTest "${test_command}" "${expect_return}" "${expect_out}"
    tmp_result=$?
    if [ ${tmp_result} -ne 0 ];then
        error_flag=1
    fi

    local test_command="cdwkdir_lock ./cd_work_dir_test.bash ${lock_file}"
    local expect_return=1
    local expect_out=
    local supply_text="ロックされている状態にて"
    execTest "${test_command}" "${expect_return}" "${expect_out}" "${supply_text}"
    tmp_result=$?
    if [ ${tmp_result} -ne 0 ];then
        error_flag=1
    fi

    rm -f ${lock_file}
    local test_command="cdwkdir_lock ./cd_work_dir_test.bash ${lock_file}"
    local expect_return=0
    local expect_out=
    local supply_text="ロックされていない状態にて"
    execTest "${test_command}" "${expect_return}" "${expect_out}" "${supply_text}"
    tmp_result=$?
    if [ ${tmp_result} -ne 0 ];then
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
    #返り値の比較※何故かlocal変数の定義と標準出力の代入を同時に行うと$?で結果がとれなかった
    local result_out
    result_out="$(${command})"
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
    echo "${1} を実行 *****************"
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


echo "-----cdwkdir_usageテスト開始-----"
cdwkdir_usage_test
echo "-----cdwkdir_usageテスト完了-----"
echo
echo "-----cdwkdir_lockテスト開始-----"
cdwkdir_lock_test
echo "-----cdwkdir_lockテスト完了-----"
