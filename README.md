# tools
個人で使うツール

##ssh_connect_suggest.bash
ssh [tab]と入力したときに ~/.ssh/config に設定しているHost名を候補として表示させる。

###[設定方法]  
このファイルをダウンロードして配置し、  
~/.bashrc 内でsource でファイルを読み込む。  
例：  
~/ssh_connect_suggest.bashにファイルをダウンロード

~/.bashrc 内に以下一行を追加  
source ~/ssh_connect_suggest.bash

ターミナルで以下コマンドを叩く  
source ~/.bashrc

##cd_work_dir.bash
プロジェクト作業ルートディレクトリへ移動するためのスクリプト  

プロジェクト作業ルートディレクトリへ移動  
cdwkdir mv [プロジェクト名]  
プロジェクト追加  
cdwkdir add [プロジェクト名] [プロジェクト作業ルートパス]  
プロジェクト削除  
cdwkdir delete [プロジェクト名]  
プロジェクト一覧表示  
cdwkdir list

.bashrcに
alias cdwkdir='. /some_dir/cd_work_dir.bash /some_dir/cd_work_dir.bash'
を記入して使う
