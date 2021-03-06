<?php

/**
   jqRealtime <https://github.com/simonoche/jqrealtime>
   Copyright (C) 2013 Simon Lamellière <simon@lamellie.re>

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU Affero General Public License as
   published by the Free Software Foundation, either version 3 of the
   License, or (at your option) any later version.

   Very basic and perfectible example in PHP, using cURL

**/

class jqRealtime
{
	static function push_all($data)
	{
		self::push("all", $data);
	}

	static function push($user_id, $data)
	{
		global $jqrealtime;

		// Prepare data
		$data = array(
			"token" => $jqrealtime["token"],
			"uid" => $user_id,
			"data" => json_encode($data)
		);

		// Curl it
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, $jqrealtime["pusher"]);
		curl_setopt($ch, CURLOPT_POST, 1);
		curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($data));
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

		// Get Output
		$server_output = curl_exec($ch);

		// Close curl
		curl_close ($ch);

		// Return result
		$result = json_decode($server_output);

		// Check result
		if(is_object($result))
			return $result;

		// And error has occured ?
		return -1;
	}
}

?>