<?php 
	
	require("config.inc.php");
	require("lib/jqrealtime.class.php");

	// Random Color
	function random_color_part() {
		return str_pad( dechex( mt_rand( 0, 255 ) ), 2, '0', STR_PAD_LEFT);
	}

	function random_color() {
		return random_color_part() . random_color_part() . random_color_part();
	}

	// Push Ball Test
	jqRealtime::push("all", array("astball" => 
			array(
				"ballid" => 100,
				"digit" => (string) $_REQUEST["digit"]
			)
		));

?>