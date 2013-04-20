#!/usr/bin/php5 -q
<?php

    /**
       jqRealtime <https://github.com/simonoche/jqrealtime>
       Copyright (C) 2013 Simon Lamellière <simon@lamellie.re>

       This program is free software: you can redistribute it and/or modify
       it under the terms of the GNU Affero General Public License as
       published by the Free Software Foundation, either version 3 of the
       License, or (at your option) any later version.

        @purpose:
        Caller can move balls on a webpage with phone digits (DTMF)
        (useless, but fun...)

    **/

    // !!!!!! TODO (example not working yet)
	require_once "phpagi.php";
    require_once "../php/lib/jqrealtime.class.php";

	$agi = new AGI();

	// Unique ID of call
	$test = $agi->get_variable("UNIQUEID");
	$test = $test['data'];
	define("UNIQUEID", $test);

	// Callerid
	$test = $agi->get_variable("CALLERID(num)");
	$test = $test['data'];
	define("CALLERID", $test);

    // 
	$bid = file_get_contents("/var/lib/asterisk/agi-bin/balls");
	$bIDD = (int) $bid + 1;

	file_put_contents("/var/lib/asterisk/agi-bin/balls", $bIDD);


	$agi->stream_file("fr/the-new-number-is");
	$agi->say_number($bIDD);
	ball();

	$i=0;

    function ball()
    {
        global $agi, $bIDD, $i;
        $cd1 = $agi->get_data("silence/1", 7000, 1);

        if(trim($cd1["result"]))
        {
            $i=0;
            $result = file_get_contents("http://localhost:8000/34psend?bid=".$bIDD."&digit=" . $cd1["result");
            $check = json_decode($result);
        }
        else
        {
            if(++$i > 4)
            {
                    $agi->hangup();
                    exit;
            }
        }

        ball();
    }

    file_get_contents("http://localhost:8000/34pbye?sender=".md5(CALLERID));

    $agi->hangup();

?>