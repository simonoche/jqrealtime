<?php

	require "config.inc.php";
	require "lib/jqrealtime.class.php";

	// Send message ?
	if(isset($_REQUEST["user_id"]) && isset($_REQUEST["message"]))
	{
		jqRealtime::push($_REQUEST["user_id"], array("message" => $_REQUEST["message"]));
	}

?>
<h1>broadcast a message to a user</h1>
<form action="broadcast.php">
	<input type="text" name="user_id" placeholder="UserId">
	<input type="text" name="message" placeholder="Your message">
	<input type="submit">
</form>