#!/usr/bin/env bash

# 引数がない場合は exec 経由での呼び出しに切り替え
# [ ! "$0" = 'bash' ] && {
# 	[ "$#" -eq 0 ] && exec /usr/bin/env bash --rcfile "$0" "$@"
# }

ORIG_SDX_SERVER_NAME="$SDX_SERVER_NAME"

# .bashrc を読み込む
# [ -r ~/.bashrc ] && {
#         pushd ~ > /dev/null
#         . .bashrc
#         popd > /dev/null
# }

# カレントディレクトリから .env と .env.servername を読み込む
_load_dot_env() {
	if [ ! -e ".env" ]; then
		return 0
	fi
	. .env

	if [ "$SDX_SERVER_NAME" = '' ]; then
		return 0
	fi

	if [ -e ".env.$SDX_SERVER_NAME" ]; then
		. ".env.$SDX_SERVER_NAME"
	fi
	return 1
}

# ディレクトリ $1 から .env や .env.servername を読み環境変数 SDX_SERVER_NAME の値を返す
# $1 の省略時はカレントディレクトリのまま
_get_env_sdx_server_name() {
	local SDX_SERVER_NAME=""
	if [ ! "$1" = "" ]; then
		cd $1
	fi
	_load_dot_env

	if [ "$SDX_SERVER_NAME" = '' ]; then
		# 見つからなかった
		return 0
	fi

	# 見つかった
	echo "$SDX_SERVER_NAME"
	return 1
}

# 仮想マシンかどうかを表す環境変数を返す
_get_sdx_virtual_machine() {
	local SDX_VIRTUAL_MACHINE=""
	if [ ! "$1" = "" ]; then
		cd $1
	fi
	_load_dot_env

	if [ "$SDX_VIRTUAL_MACHINE" = '' ]; then
		# 見つからなかった
		return 0
	fi

	# 見つかった
	echo "$SDX_VIRTUAL_MACHINE"
	return 1
}

# .env ファイルがあるディレクトリの階層（ホームディレクトリ）を返す
_get_site_home() {
	while [ ! $PWD = "/" ]
	do
		if [ ! -e ".env" ]; then
			cd ..
			continue
		fi

		local name=`_get_env_sdx_server_name $PWD`
		if [ "$name" = '' ]; then
			cd ..
			continue
		fi

		echo $PWD
		return 1
	done
	return 0
}

# カレントディレクトリにおける SDX_SERVER_NAME を返す
_get_sdx_server_name() {
	# サイトのホームディレクトリを探す
	local site_home=`_get_site_home`
	if [ "$site_home" = '' ]; then
		return 0
	fi

	local name="$ORIG_SDX_SERVER_NAME"
	cd "$site_home"
	if [ "$name" = '' ]; then
		name=`_get_env_sdx_server_name $site_home`
	fi
	echo $name
	return 1
}

# サーバ名を着色して出力する
_print_sdx_server_name() {
	# サイトのホームディレクトリを探す
	local site_home=`_get_site_home`
	if [ "$site_home" = '' ]; then
		# 設定が見つからなかった 灰色
		echo -ne "\033[1;30;47m[OUT-OF-SITE-HOME]\033[0;30;47m .env not found \033[0m"
		return 0
	fi

	local name="$ORIG_SDX_SERVER_NAME"
	cd "$site_home"
	if [ "$name" = '' ]; then
		name=`_get_env_sdx_server_name $site_home`
	fi

	# 仮想サーバか？
	if [ "$SDX_VIRTUAL_MACHINE" = '1' ]; then
		# 仮想サーバ 青
		echo -ne "\033[1;44;37m[VIRTUAL]\033[0;44;37m SDX_SERVER_NAME=$name \033[0m"
		return 0
	fi

	# テストサーバか？
	if echo $name | grep "test" > /dev/null; then
		# テストサーバ 緑
		echo -ne "\033[1;42;37m[TEST]\033[0;42;37m SDX_SERVER_NAME=$name \033[0m"
		return 0
	fi

	# 本番サーバ 赤
	echo -ne "\033[1;41;37m[PRODUCTION]\033[0;41;37m SDX_SERVER_NAME=$name \033[0m"
	return 0
}

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
