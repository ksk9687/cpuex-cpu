<?php



if($argv[1] == "-l"){
	$path = "./tmp/".$argv[2]."/";
	$itr = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($path));

	$data =<<<EOM
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package SuperScalarComponents is

EOM;
	foreach ($itr as $elem) {
		if ($elem->isFile()) {
			$data .= file_get_contents($elem->getPathname());
		}
	}
	$data .=<<<EOM
end package;

EOM;
	mkdir_recursive("./".$argv[3]);
	file_put_contents("./".$argv[3],$data);
}else{
	$text = x2u(file_get_contents($argv[2]));

	$data = "\n";
	if(preg_match_all('/entity(.*?)end /isu',$text,$match)){
		foreach ($match[1] as $entity){
		 $data .= "component".$entity."end component;\n\n";
		}
	}
	mkdir_recursive("./tmp/".$argv[1]);
	file_put_contents($argv[3],u2s($data));
}

function mkdir_recursive($pathname, $mode = "0777"){
	is_dir(dirname($pathname)) || mkdir_recursive(dirname($pathname), $mode);
	return is_dir($pathname) || @mkdir($pathname, $mode);
}
function x2u($data){
	return mb_convert_encoding($data,"utf8","SJIS-win,utf-8,auto");
}
function u2s($data){
	return mb_convert_encoding($data,"SJIS-win","utf8");
}