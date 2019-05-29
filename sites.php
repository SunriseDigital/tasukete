<?php
require dirname(__FILE__).'/get_dirs.php';

echo implode(" ", get_dirs("/home/sites"));
