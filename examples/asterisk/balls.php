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
        
        Simply make a symbolic link of this and kill-ball.php in /var/lib/asterisk/agi-bin/
        Ensure asterisk has permission to execute and read this AGI file

        In Your dialplan (such as extensions.conf or extensions_custom.conf)
        do something like that : 

        [from-internal-xfer]
        exten => 188,1,Answer
        exten => 188,n,AGI(balls.php, ${UNIQUEID})
        exten => 188,n,Hangup
        exten => h,1,AGI(kill-ball.php, ${UNIQUEID})
    **/

    // Include configuration
	require_once "/var/lib/asterisk/agi-bin/phpagi.php";
    require_once dirname(__FILE__) . "/../php/config.inc.php";
    require_once dirname(__FILE__) . "/../php/lib/jqrealtime.class.php";

    // Init AGI
    $agi = new AGI();
    $i = 0;

    // UniqueId
    $guid = $argv[1];

    // Find a new ball id
    $count = (int) file_get_contents(dirname(__FILE__)."/ball_count.txt");
    file_put_contents(dirname(__FILE__)."/ball_count.txt", ++$count);
    $bid = $count;

    // Init the Ball State
    jqRealtime::push("all", array("astball" => 
        array(
           "ballid" => md5($guid),
           "ballnu" => $bid,
           "digit" => "5",
           "action" => "create"
        )
    ));

    // Tell the ball number
	// $agi->stream_file("fr/the-new-number-is");
	$agi->say_number($bid);

    // Execute our loop
	ball();

    // Func loop
    function ball()
    {
        global $agi, $bid, $guid, $i;

        // Get digits
        $cd1 = $agi->get_data("silence/1", 7000, 1);

        if(trim($cd1["result"]))
        {
            $i=0;

            // Push Ball State
            jqRealtime::push("all", array("astball" => 
                array(
                   "ballid" => md5($guid),
                   "ballnu" => $bid,
                   "digit" => (string) $cd1["result"],
                   "action" => "move"
                )
            ));
        }
        else
        {
            // We wait too much
            if(++$i > 4)
            {
                // Hangup now
                $agi->hangup();
                exit;
            }
        }

        ball();
    }

    // We always hangup
    $agi->hangup();

?>