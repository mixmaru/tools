# tools
個人で使うツール

#ssh_connect_suggest.bash
ssh [tab]と入力したときに ~/.ssh/config に設定しているHost名を候補として表示させる。

[設定方法]
このファイルをダウンロードして配置し、
~/.bashrc 内でsource でファイルを読み込む。
例：
~/ssh_connect_suggest.bashにファイルをダウンロード

~/.bashrc 内に以下一行を追加
source ~/ssh_connect_suggest.bash

ターミナルで以下コマンドを叩く
source ~/.bashrc
