#!/bin/bash

#cd_work_dir補完用
_cd_work_dir_suggest () {
    local setting_file=$(cd ~/.cdwkdir; pwd)/project_list
    case "${COMP_CWORD}" in
        #第一引数
        "1" )
            #アクション引数をサジェスト
            local action_commands=$(compgen -W "mv add delete list" -- "${COMP_WORDS[${COMP_CWORD}]}")
            COMPREPLY=(${action_commands[@]})
            ;;
        #第二引数
        "2" )
            #第一引数がmv か deleteの場合で、setting_fileが存在するにのみ、プロジェクト名をサジェスト
            if ( [ ${COMP_WORDS[1]} = "mv" ] || [ ${COMP_WORDS[1]} = "delete" ] ) && [ -e ${setting_file} ]; then
                local tmp_command="cat ${setting_file} | awk '{print \$1}'"
                local projects=($(eval ${tmp_command}))
                tmp_command="compgen -W \"${projects[@]}\" -- \"${COMP_WORDS[${COMP_CWORD}]}\""
                local suggest_projects=($(eval ${tmp_command}))
                COMPREPLY=(${suggest_projects[@]})
            fi
            ;;
    esac
}
complete -F _cd_work_dir_suggest cdwkdir
