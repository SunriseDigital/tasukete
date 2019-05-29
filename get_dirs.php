<?php

/**
 * 指定したディレクトリ直下のディレクトリをソートして返す。
 * @return array
 */
function get_dirs($basedir) {
  $d = dir($basedir);
  if($d === false) throw new Exception("`{$basedir}`は存在しません");
  $sites = array();
  while (false !== ($entry = $d->read())) {
    if ($entry == '.' || $entry == '..' || !is_dir("$basedir/$entry")) {
      continue;
    }
    $sites[] = trim($entry);
  }
  sort($sites);
  return $sites;
}