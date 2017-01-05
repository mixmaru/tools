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


echo "-----cdwkdir_usageテスト開始-----"
cdwkdir_usage_error=$(cdwkdir_usage_test)
if [ $? -eq 0 ]; then
    echo "ok"
else
    echo "ng"
    echo "${cdwkdir_usage_error}"
fi
echo "-----cdwkdir_usageテスト完了-----"

echo テスト完了
