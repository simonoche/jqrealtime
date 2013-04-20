<?php

	$mysql = mysql_connect("localhost", "root", "");
	mysql_select_db("jqrealtime");

	// Poller Configuration
	$jqrealtime = array(
		"pusher" => "http://localhost:8080/push",
		"poller" => "http://localhost:8080/poll",
		"token" => "bf3cc858ce88c3fcebcf3e7c691983a28b8dabba"
		);

?>