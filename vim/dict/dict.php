<?php
$functions = get_defined_functions();
sort($functions['internal']);
echo join("\n", $functions['internal']);
