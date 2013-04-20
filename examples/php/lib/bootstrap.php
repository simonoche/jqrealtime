<?php

	// Create a session for user
	if(!isset($_COOKIE["jqr"]))
	{
		$_COOKIE["jqr"] = sha1(time());

		// Set the cookie
		setcookie("jqr", $_COOKIE["jqr"], time()+360000, false, "");

		// Insert USER
		mysql_query("INSERT INTO sessions SET cookie = \"" . mysql_real_escape_string($_COOKIE["jqr"]) . "\", user_id = ((SELECT max(s2.user_id) FROM sessions s2 LIMIT 1)+1)");
	}

	// Fetch USER
	$user = mysql_fetch_object(mysql_query("SELECT * FROM sessions WHERE cookie = \"".mysql_real_escape_string($_COOKIE["jqr"])."\""));

	if(!$user)
		die('Invalid session (flush your cookies)');

?>