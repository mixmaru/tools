#!/bin/bash

#ssh接続先補完用
_ssh () {
	local ssh_config=~/.ssh/config
	local host=()
	if [ -e ${ssh_config} ]
		then
			if [ ${COMP_CWORD} -eq 1 ]
				then
					while read line; do
						host=("${host[@]}" "`echo ${line} | cut -d ' ' -f 2`")
					done < <(cat $ssh_config | grep "^Host")
					local host_string=${host[@]}
					COMPREPLY=($(compgen -W "${host_string}" -- "${COMP_WORDS[${COMP_CWORD}]}"))
			fi
	fi
}
complete -F _ssh ssh
