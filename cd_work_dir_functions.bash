#!/bin/bash

#usage表示
function cdwkdir_usage(){
cat <<_EOT_
Usage:
  mv        project_name                projectのディレクトリへ移動する
  add       project_name dir_path       プロジェクト名をproject_name、ディレクトリパスをdir_pathとして新規追加する
  delete    project_name                projectを削除する
  list                                  登録されているproject一覧を表示する
_EOT_
}

#排他ロック。参考）http://qiita.com/hidetzu/items/11f92f941efbb182f757
#cdwkdir_lock ロック対象スクリプトファイルパス 作成するロックファイルパス
function cdwkdir_lock(){
    local script_file=$1
    local lock_file=$2
    #引数存在チェック
    if [ -z "${script_file}" ] || [ -z "${lock_file}" ]; then
        return 1
    fi

    local is_lock="no"
    ln -s ${script_file} ${lock_file} 2> /dev/null || is_lock="yes"
    if [ ${is_lock} = "yes" ]; then
        return 1
    else
        return 0
    fi
}

#カレントディレクトリの移動
#cdwkdir_move プロジェクト名 プロジェクト設定リストファイルパス
function cdwkdir_move(){
    local project_name=$1
    local project_list_file=$2
    #引数存在チェック
    if [ -z "${project_name}" ] || [ -z "${project_list_file}" ]; then
        return 1
    fi

    #指定プロジェクトの行数を取得
    local count_command="cat ${project_list_file} | awk 'BEGIN{count=0} \$1==\"${project_name}\"{count+=1} END{print count}'"
    local count=$(eval ${count_command})

    #行数が1なら正常。そうでないなら異常なので処理終了
    if [ ${count} -eq 0 ]; then
        error+=("プロジェクト【${project_name}】は存在しません")
        return 1
    elif [ ${count} -ge 2 ]; then
        error+=("プロジェクト【${project_name}】の設定が複数あります。${project_list_file} を確認してください")
        return 1
    fi

    #パスを取り出す
    local path_command="cat ${project_list_file} | awk '\$1==\"${project_name}\"{print \$2}'"
    local target_path=$(eval ${path_command})
    cd ${target_path}
}

#プロジェクトパスデータの追加
#cdwkdir_add プロジェクト名 プロジェクトディレクトリパス プロジェクト設定リストファイルパス
function cdwkdir_add(){
    local project_name=$1
    local project_path=$2
    local project_list_file=$3
    #引数存在チェック
    if [ -z "${project_name}" ] || [ -z "${project_path}" ] || [ -z "${project_list_file}" ]; then
        return 1
    fi

    #存在しないかチェック
    local tmp_command="cat ${project_list_file} | awk '\$1==\"${project_name}\"{print \$1}'"
    local result=($(eval ${tmp_command}))
    if [ ${#result[@]} -eq 0 ];then
        #追加処理
        #相対パスを絶対パスに変換して追記
        local absolute_path=$(cd ${project_path} && pwd)
        if [ -z "${absolute_path}" ]; then
            error="${project_path}は存在しません"
            return 1
        elif [ "${absolute_path}" != "/" ]; then
            #末は/をつけておく
            absolute_path="${absolute_path}/"
        fi
        echo "${project_name} ${absolute_path}" >> ${project_list_file}
        return 0
    else
        error+=("すでに${project_name}が存在します")
        return 1
    fi
}

#プロジェクト削除 delete プロジェクト名
#cdwkdir_delete プロジェクト名 プロジェクト設定リストファイルパス プロジェクト設定リストファイル変更時のテンポラリファイルパス
function cdwkdir_delete(){
    local project_name=$1
    local project_list_file=$2
    local project_tmp_file=$3
    #引数存在チェック
    if [ -z "${project_name}" ] || [ -z "${project_list_file}" ] || [ -z "${project_tmp_file}" ]; then
        return 1
    fi

    local tmp_command="cat ${project_list_file} | awk '\$1!=\"${project_name}\"{print \$0}'"

    #指定プロジェクトを除去した設定ファイルの一時ファイルを作成
    eval ${tmp_command} > ${project_tmp_file}
    #元ファイルと比較して、変更があれば元ファイルを上書きする
    local tmp_command="diff ${project_list_file} ${project_tmp_file}"
    local diff_res=$(eval ${tmp_command})

    if [ -n "${diff_res}" ];then
        cat ${project_tmp_file} > ${project_list_file}
        rm ${project_tmp_file}
        return 0
    else
        error+=("プロジェクト【${project_name}】は存在しません")
        rm ${project_tmp_file}
        return 1
    fi
}

#プロジェクト一覧表示
#cdwkdir_list プロジェクト設定リストファイルパス
function cdwkdir_list(){
    local project_list_file=$1
    #引数存在チェック
    if [ -z "${project_list_file}" ]; then
        return 1
    fi

    local tmp_command="cat ${project_list_file} | awk '{print \$1}'"
    eval ${tmp_command}
}
