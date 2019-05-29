#!/usr/bin/env bash


# よく使うコマンドを一覧表示して呼び出すインターフェイス
# tasukete か _ で呼べる
tasukete() {
  local input="$1"
  if [ "$input" = "" ]; then
    echo -e "\033[1mtasukete\033[0m"
    echo -e "\033[1m========\033[0m"
    echo ""
    echo -e "\033[1mUsage:\033[0m"
    echo "  tasukete [コマンド名]"
    echo "  _ [コマンド名]"
    echo ""
    echo "  コマンド名を入力すると対応するコマンドを実行します。"
    echo "  TABキーによる補完入力に対応しています。"
    echo ""
    echo -e "\033[1mCommand List:\033[0m"
    local command=`php ~/tasukete/commands.php list < /dev/null`
    if [ "$command" = "" ]; then
      echo "  tasukete に登録されているコマンドはありません。"
    else
      echo "$command"
    fi
    echo ""
    echo -e "\033[1mRegister:\033[0m"
    echo "  コマンドを登録するには ~/.tasukete に"
    echo ""
    echo "  hello_command => echo \"hello!\""
    echo ""
    echo "  の形式で定義ファイルを作成してください。"
    echo "  コマンド名にスペースは使えません。"
    echo ""
    return 0
  fi

	local command=`php ~/tasukete/commands.php select $input < /dev/null`
  if [ "$command" = "" ]; then
    echo "'$input' コマンドが見つかりません。"
    return 0
  fi

  eval "$command"
}
_tasukete_complete() {
  COMPREPLY=( $(compgen -W "`php ~/tasukete/commands.php < /dev/null`" ${COMP_WORDS[COMP_CWORD]}))
}
complete -F _tasukete_complete tasukete
alias _=tasukete
complete -F _tasukete_complete _

# サイト一覧を表示するコマンド
sites() {
	if [ ! -e /home/sites ]; then
		echo -e "\033[1m/home/sitesディレクトリが存在しません。\033[0m" 
		return 1
	fi

	if [ ! "$1" = "" ]; then
		cd /home/sites/$1
    return 0
	fi

  echo -e "\033[1msites\033[0m"
  echo -e "\033[1m=====\033[0m"
  echo ""
  echo -e "\033[1mUsage:\033[0m"
  echo "  sites [ディレクトリ名]"
  echo ""
  echo "  サイト名を指定するとそのディレクトリに移動します。"
  echo "  TABキーによる補完入力に対応しています。"
  echo ""
  echo -e "\033[1mSite List:\033[0m"

  local ss=(`php ~/tasukete/sites.php < /dev/null`)
  local e
  for e in ${ss[@]}
  do
    echo "  ${e}"
  done
}

# sites
_sites_complete() {
  COMPREPLY=( $(compgen -W "`php ~/tasukete/sites.php < /dev/null`" ${COMP_WORDS[COMP_CWORD]}))
}
complete -F _sites_complete sites


# sources
sources() {
	if [ ! -e /home/source ]; then
		echo -e "\033[1m/home/sourceディレクトリが存在しません。\033[0m" 
		return 1
	fi

	if [ ! "$1" = "" ]; then
		cd /home/source/$1
    return 0
	fi

  echo -e "\033[1msources\033[0m"
  echo -e "\033[1m=====\033[0m"
  echo ""
  echo -e "\033[1mUsage:\033[0m"
  echo "  sources [ディレクトリ名]"
  echo ""
  echo "  サイト名を指定するとそのディレクトリに移動します。"
  echo "  TABキーによる補完入力に対応しています。"
  echo ""
  echo -e "\033[1mSite List:\033[0m"

  local ss=(`php ~/tasukete/sources.php < /dev/null`)
  local e
  for e in ${ss[@]}
  do
    echo "  ${e}"
  done
}
_sources_complete() {
  COMPREPLY=( $(compgen -W "`php ~/tasukete/sources.php < /dev/null`" ${COMP_WORDS[COMP_CWORD]}))
}
complete -F _sources_complete sources

echo ''
echo 'This text is written in UTF-8.'
echo ''
echo '通常のシェルコマンドに加えて以下のコマンドが利用可能です。'
echo 'TAB キーによる入力補完に対応しています。'
echo ''
echo 'sites     /home/sites 内にあるサイト一覧を表示、選択'
echo 'source     /home/sites 内にあるサイト一覧を表示、選択'
echo 'tasukete  よく使うコマンド一覧を表示、選択'
echo '_         tasukete コマンドの別名。アンダースコア。'
# echo ''
# echo -e ".env がない場所では \033[1;30;47m[OUT-OF-SITE-HOME]\033[0;30;47m .env not found \033[0m と表示されます。"
