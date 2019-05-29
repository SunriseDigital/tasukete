<?php

main();

/**
 * tasukete コマンド
 * =================
 * ~/.tasukete に書いたカスタム定義のデータを表示できます。
 * 引数なしで呼び出した場合はコマンドリストの出力、引数を付けた場合は選択されたコマンドの内容を返します。
 * 
 * .tasukete ファイルの書式
 * ------------------------
 * エイリアス => コマンド名
 * 
 * ### 例
 * hello => echo "Hello!"
 */
function main() {
  $entries = array();
  foreach (get_custom_entries() as $key => $cmd) {
    $entries[$key] = $cmd;
  }

  if ($_SERVER['argc'] <= 1) {
    echo implode(" ", array_keys($entries));
  } else {
    switch($_SERVER['argv'][1]){
    case 'list':
      show_commands($entries);
      break;
    case 'select':
      select_command($entries, $_SERVER['argv'][2]);
      break;
    }
  }
}

/**
 * コマンドリストをコンソールに出力する
 * @param array $entries
 */
function show_commands(array $entries) {
  $longest = 0;
  foreach ($entries as $key => $entry) {
    $longest = max(strlen($key), $longest);
  }
  foreach ($entries as $key => $entry) {
    fprintf(STDOUT, "  \033[1m%${longest}s\033[0m => %s\n", $key, $entry);
  }
}

/**
 * 選択されたコマンドの内容を返す
 * @param array $entries
 * @param string $selected
 */
function select_command(array $entries, $selected) {
  if (isset($entries[$selected])) {
    fprintf(STDOUT, "%s", $entries[$selected]);
  }
}

/**
 * ユーザ定義の tasukete リストを返す
 * @return array
 */
function get_custom_entries() {
  $path = "/home/$_SERVER[USER]/.tasukete";
  if (!file_exists($path)) {
    return array();
  }

  $entries = array();
  foreach (file($path) as $line) {
    $line = trim($line);
    if (strpos($line, '=>') === false) {
      continue;
    }
    if ($line[0] == '#') {
      continue;
    }
    list($key, $value) = explode('=>', $line);
    $entries[trim($key)] = trim($value);
  }
  return $entries;
}
